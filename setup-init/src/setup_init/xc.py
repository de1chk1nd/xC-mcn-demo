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

    # Extract certificates and private key separately, then combine.
    # OpenSSL 3.x with -legacy still produces ENCRYPTED PRIVATE KEY
    # even with -passout pass:, so we must use -nodes explicitly.
    xc_dir = pem_path.parent
    cert_tmp = xc_dir / "xc-certs.tmp"
    key_tmp = xc_dir / "xc-key.tmp"
    p12_pass = xc_config.p12_pwd

    def _run_openssl(*args):
        """Run openssl, try with -legacy first (OpenSSL 3.x)."""
        base = [openssl_bin, *args]
        r = subprocess.run(base + ["-legacy"], capture_output=True, text=True)
        if r.returncode != 0:
            r = subprocess.run(base, capture_output=True, text=True)
        return r

    # Step 1: Extract certificates only (-nokeys)
    result = _run_openssl(
        "pkcs12", "-in", str(p12_path),
        "-out", str(cert_tmp),
        "-passin", f"pass:{p12_pass}",
        "-nokeys",
    )
    if result.returncode != 0:
        raise RuntimeError(f"Failed to extract certs: {result.stderr.strip()}")

    # Step 2: Extract private key only (-nocerts -nodes for unencrypted)
    result = _run_openssl(
        "pkcs12", "-in", str(p12_path),
        "-out", str(key_tmp),
        "-passin", f"pass:{p12_pass}",
        "-nocerts", "-nodes",
    )
    if result.returncode != 0:
        raise RuntimeError(f"Failed to extract key: {result.stderr.strip()}")

    # Step 3: Combine into clean PEM (strip Bag Attributes)
    clean_lines = []
    for tmp_file in [key_tmp, cert_tmp]:
        in_block = False
        with open(tmp_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.rstrip("\n")
                if line.startswith("-----BEGIN "):
                    in_block = True
                if in_block:
                    clean_lines.append(line)
                if line.startswith("-----END "):
                    in_block = False

    with open(pem_path, "w", encoding="utf-8") as f:
        f.write("\n".join(clean_lines) + "\n")

    # Cleanup temp files
    cert_tmp.unlink(missing_ok=True)
    key_tmp.unlink(missing_ok=True)

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
    Fetch the tenant's default Anycast IP.

    Strategy:
    1. If already set in config, return it (manual override).
    2. Query the xC API (whoami) to get the tenant CNAME, then
       create a temporary HTTP LB, resolve its FQDN, and delete it.
       (Not implemented — too invasive for an init script.)
    3. Prompt the user.

    The Anycast IP is tenant-specific and cannot be reliably resolved
    via public DNS or a single API call. The user must provide it.

    How to find it: xC Console -> DNS Management -> check the IP
    that delegated domains point to, or check an existing HTTP LB's
    CNAME record.

    Args:
        xc_config: xC configuration
        base_dir: Base directory (setup-init/)
        timeout: HTTP request timeout in seconds

    Returns:
        Anycast IP address as string, or empty string on failure
    """
    # If already set in config, reuse it
    if xc_config.tenant_anycast_ip:
        print(f"  Anycast IP (from config): {xc_config.tenant_anycast_ip}")
        return xc_config.tenant_anycast_ip

    print(f"\nTenant Anycast IP is not set in config.yaml.")
    print(f"  This IP is needed for /etc/hosts entries of xC use-case apps.")
    print(f"  You can find it in the xC Console:")
    print(f"    - DNS Management -> check delegated domain CNAME target IP")
    print(f"    - Or: create any HTTP LB and check its advertised IP")
    print()

    ip = input("  Enter tenant Anycast IP (or press Enter to skip): ").strip()

    if ip:
        print(f"  Anycast IP: {ip}")
        return ip

    print("  Skipped — /etc/hosts use-case app entries will be incomplete.")
    return ""
