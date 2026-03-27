"""F5 Distributed Cloud (xC) certificate handling and tenant discovery."""

import os
import socket
import subprocess
import sys
from pathlib import Path

import requests

from setup_init.config import XCConfig


def convert_p12_to_pem(
    xc_config: XCConfig,
    base_dir: Path,
    openssl_bin: str = "/usr/bin/openssl",
) -> Path:
    """
    Convert xC P12 certificate to PEM format for curl/API usage.

    The P12 file contains the API certificate and private key. This function
    extracts both into a single PEM file that can be used with curl.

    Args:
        xc_config: xC configuration with P12 path and password
        base_dir: Base directory (setup-init/)
        openssl_bin: Path to OpenSSL binary

    Returns:
        Path to the generated PEM file

    Raises:
        RuntimeError: If conversion fails
    """
    # Resolve P12 file path (may be relative to base_dir)
    p12_path = Path(xc_config.p12_auth)
    if not p12_path.is_absolute():
        p12_path = (base_dir / xc_config.p12_auth).resolve()

    if not p12_path.is_file():
        raise RuntimeError(f"P12 certificate not found: {p12_path}")

    # Output PEM file in .xC directory
    xc_dir = base_dir / ".xC"
    xc_dir.mkdir(exist_ok=True)
    pem_path = xc_dir / "xc-curl.crt.pem"

    print(f"\nConverting P12 certificate to PEM...")
    print(f"  Source: {p12_path}")
    print(f"  Target: {pem_path}")

    # Build OpenSSL command
    # Note: -legacy flag is needed for OpenSSL 3.x with older P12 files
    cmdline = [
        openssl_bin, "pkcs12",
        "-in", str(p12_path),
        "-out", str(pem_path),
        "-passin", f"pass:{xc_config.p12_pwd}",
        "-passout", f"pass:{xc_config.p12_pwd}",
    ]

    # Try with -legacy flag first (OpenSSL 3.x)
    result = subprocess.run(
        cmdline + ["-legacy"],
        capture_output=True,
        text=True,
    )

    # If -legacy fails, try without it (older OpenSSL)
    if result.returncode != 0:
        result = subprocess.run(
            cmdline,
            capture_output=True,
            text=True,
        )

    if result.returncode != 0:
        raise RuntimeError(
            f"Failed to convert P12 to PEM: {result.stderr.strip()}"
        )

    # Set secure permissions
    os.chmod(pem_path, 0o600)

    print(f"  PEM certificate created successfully")
    return pem_path


def get_pem_path(base_dir: Path) -> Path:
    """Return the path to the xC PEM certificate."""
    return base_dir / ".xC" / "xc-curl.crt.pem"


def remove_pem(base_dir: Path) -> None:
    """Remove the generated PEM certificate (used during teardown)."""
    pem_path = get_pem_path(base_dir)
    if pem_path.exists():
        pem_path.unlink()
        print(f"Removed: {pem_path}")


def fetch_tenant_anycast_ip(
    xc_config: XCConfig,
    base_dir: Path,
    timeout: int = 10,
) -> str:
    """
    Resolve the tenant's default Anycast IP address.

    Uses a DNS lookup on the tenant's console hostname, which resolves
    to the Anycast IP advertised by the F5 Distributed Cloud global network.

    Args:
        xc_config: xC configuration with tenant name
        base_dir: Base directory (setup-init/)
        timeout: DNS timeout in seconds

    Returns:
        Anycast IP address as string, or empty string on failure
    """
    # The tenant's console FQDN resolves to the Anycast IP
    tenant_fqdn = f"{xc_config.tenant}.console.ves.volterra.io"

    print(f"\nResolving tenant Anycast IP...")
    print(f"  Tenant FQDN: {tenant_fqdn}")

    try:
        ip = socket.gethostbyname(tenant_fqdn)
        print(f"  Anycast IP:  {ip}")
        return ip
    except socket.gaierror as e:
        print(f"  WARNING: Could not resolve {tenant_fqdn}: {e}")
        print(f"  Trying API fallback...")

    # Fallback: query the xC API for the VIP
    pem_path = get_pem_path(base_dir)
    if not pem_path.is_file():
        print(f"  WARNING: PEM not available, skipping API fallback")
        return ""

    try:
        url = f"{xc_config.tenant_api}/config/namespaces/system/virtual_ips"
        resp = requests.get(
            url,
            cert=str(pem_path),
            timeout=timeout,
        )
        resp.raise_for_status()
        items = resp.json().get("items", [])
        if items:
            ip = items[0].get("spec", {}).get("vip", "")
            if ip:
                print(f"  Anycast IP (via API): {ip}")
                return ip
    except Exception as e:
        print(f"  WARNING: API fallback failed: {e}")

    return ""
