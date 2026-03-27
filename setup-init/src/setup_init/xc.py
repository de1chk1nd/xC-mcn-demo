"""F5 Distributed Cloud (xC) certificate handling and tenant discovery."""

import os
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
    # -nodes / -passout pass: produces an unencrypted PEM (required by requests/curl)
    cmdline = [
        openssl_bin, "pkcs12",
        "-in", str(p12_path),
        "-out", str(pem_path),
        "-passin", f"pass:{xc_config.p12_pwd}",
        "-passout", "pass:",
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
    timeout: int = 15,
) -> str:
    """
    Fetch the tenant's default Anycast IP via the xC API.

    Queries the tenant summary endpoint which returns the default
    VIP (Virtual IP) assigned to the tenant for RE load balancers.

    Requires the PEM certificate to be generated first (P12 -> PEM).
    The PEM must be unencrypted (passout pass: during conversion).

    Args:
        xc_config: xC configuration with tenant API URL
        base_dir: Base directory (setup-init/)
        timeout: HTTP request timeout in seconds

    Returns:
        Anycast IP address as string, or empty string on failure
    """
    pem_path = get_pem_path(base_dir)
    if not pem_path.is_file():
        print("  WARNING: PEM certificate not found, cannot query xC API")
        return ""

    print(f"\nFetching tenant Anycast IP from xC API...")
    print(f"  Tenant: {xc_config.tenant}")

    url = f"{xc_config.tenant_api}/web/namespaces/system/summary"
    try:
        resp = requests.get(
            url,
            cert=str(pem_path),
            headers={"Content-Type": "application/json"},
            timeout=timeout,
        )
        resp.raise_for_status()
        data = resp.json()

        # Extract the default VIP from the tenant summary
        vip = (
            data.get("tenant_setting", {}).get("default_vip", "")
            or data.get("default_vip", "")
        )
        if vip:
            print(f"  Anycast IP: {vip}")
            return vip

        # Fallback: check alternative response keys
        for key in ("anycast_ip", "vip", "default_ip"):
            val = data.get(key, "")
            if val:
                print(f"  Anycast IP: {val}")
                return val

        # Debug: log response keys if IP not found
        print(f"  WARNING: Could not extract Anycast IP from response")
        print(f"  Response keys: {list(data.keys())}")

    except Exception as e:
        print(f"  WARNING: API call failed: {e}")

    return ""
