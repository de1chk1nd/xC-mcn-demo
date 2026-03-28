"""Certificate Authority generation for the lab environment.

Reads CA OpenSSL settings (key_size, validity, DN) from the s-certificate
tool config. Only path information comes from the project config.
"""

import os
import subprocess
import sys
from pathlib import Path

import yaml

from setup_init.config import CertPaths


CA_CONFIG_TEMPLATE = """\
prompt = no
distinguished_name = req_distinguished_name
x509_extensions = v3_ca

[ req_distinguished_name ]
C                      = {country}
ST                     = {state}
L                      = {locality}
O                      = {organization}
OU                     = {organizational_unit}
CN                     = {organization} CA

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
"""

# Default CA settings (used when s-certificate config is not available)
DEFAULT_CA_SETTINGS = {
    "openssl_bin": "/usr/bin/openssl",
    "key_size": 4096,
    "validity_days": 3650,
    "country": "DE",
    "state": "Hessen",
    "locality": "Frankfurt",
    "organization": "xC MCN Lab",
    "organizational_unit": "Demo",
}


def load_ca_settings(repo_root: Path) -> dict:
    """
    Load CA OpenSSL settings from the s-certificate tool config.

    Reads the ca: section from tools/s-certificate/config/config.yaml.
    Falls back to defaults if the config does not exist.

    Returns a dict with: openssl_bin, key_size, validity_days, and DN fields.
    """
    tool_config = repo_root / "tools" / "s-certificate" / "config" / "config.yaml"

    if not tool_config.is_file():
        print(f"  s-certificate config not found at {tool_config}")
        print(f"  Using default CA settings")
        return DEFAULT_CA_SETTINGS.copy()

    try:
        with open(tool_config, encoding="utf-8") as f:
            cfg = yaml.safe_load(f)
    except (yaml.YAMLError, OSError) as e:
        print(f"  Warning: Could not read {tool_config}: {e}")
        print(f"  Using default CA settings")
        return DEFAULT_CA_SETTINGS.copy()

    cert = cfg.get("certificate", {})
    ca_raw = cert.get("ca", {})
    ca_dn = ca_raw.get("distinguished_name", {})

    # CA DN falls back to server cert DN, then to defaults
    cert_dn = cert.get("distinguished_name", {})

    return {
        "openssl_bin": cert.get("openssl_bin", DEFAULT_CA_SETTINGS["openssl_bin"]),
        "key_size": ca_raw.get("key_size", DEFAULT_CA_SETTINGS["key_size"]),
        "validity_days": ca_raw.get("validity_days", DEFAULT_CA_SETTINGS["validity_days"]),
        "country": ca_dn.get("country", cert_dn.get("country", DEFAULT_CA_SETTINGS["country"])),
        "state": ca_dn.get("state", cert_dn.get("state", DEFAULT_CA_SETTINGS["state"])),
        "locality": ca_dn.get("locality", cert_dn.get("locality", DEFAULT_CA_SETTINGS["locality"])),
        "organization": ca_dn.get("organization", cert_dn.get("organization", DEFAULT_CA_SETTINGS["organization"])),
        "organizational_unit": ca_dn.get("organizational_unit", cert_dn.get("organizational_unit", DEFAULT_CA_SETTINGS["organizational_unit"])),
    }


def run_openssl(openssl_bin: str, *args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """
    Run an OpenSSL command.

    Raises RuntimeError if the command fails.
    """
    cmdline = [openssl_bin, *args]
    result = subprocess.run(
        cmdline,
        capture_output=capture,
        text=True,
    )
    if result.returncode != 0:
        stderr = result.stderr.strip() if capture else ""
        raise RuntimeError(
            f"OpenSSL command failed (exit {result.returncode}): "
            f"{' '.join(cmdline)}\n{stderr}"
        )
    return result


def generate_ca(cert_paths: CertPaths, base_dir: Path, repo_root: Path) -> tuple[str, str]:
    """
    Generate a new CA key and self-signed certificate.

    Reads OpenSSL settings from the s-certificate tool config.
    Uses non-interactive mode suitable for automated deployment.

    Args:
        cert_paths: Certificate path configuration (ca_dir)
        base_dir: Base directory (setup-init/)
        repo_root: Repository root (for finding s-certificate config)

    Returns:
        Tuple of (ca_key_path, ca_cert_path) relative to base_dir
    """
    # Resolve CA directory
    ca_dir = base_dir / cert_paths.ca_dir
    if not ca_dir.exists():
        print(f"Creating CA directory: {ca_dir}")
        ca_dir.mkdir(parents=True, mode=0o700)

    # Also ensure cert_dir exists for later use
    cert_dir = base_dir / cert_paths.cert_dir
    if not cert_dir.exists():
        print(f"Creating certificate directory: {cert_dir}")
        cert_dir.mkdir(parents=True, mode=0o700)

    ca_key = ca_dir / "ca.key"
    ca_cert = ca_dir / "ca.cer"

    # Check if CA already exists
    if ca_key.is_file() and ca_cert.is_file():
        print(f"CA already exists at {ca_dir}")
        return str(ca_key.relative_to(base_dir)), str(ca_cert.relative_to(base_dir))

    # Load OpenSSL settings from s-certificate config
    settings = load_ca_settings(repo_root)

    print(f"\nGenerating Certificate Authority...")
    print(f"  Key size:    {settings['key_size']} bit")
    print(f"  Validity:    {settings['validity_days']} days (~{settings['validity_days'] // 365} years)")
    print(f"  Subject:     C={settings['country']}, ST={settings['state']}, L={settings['locality']}")
    print(f"               O={settings['organization']}, OU={settings['organizational_unit']}")

    # Step 1: Generate RSA private key
    print(f"\nGenerating CA private key ({settings['key_size']} bit)...")
    run_openssl(
        settings["openssl_bin"],
        "genrsa", "-out", str(ca_key), str(settings["key_size"]),
    )
    os.chmod(ca_key, 0o600)

    # Step 2: Create self-signed CA certificate
    config_path = ca_dir / "ca.cnf"
    config_content = CA_CONFIG_TEMPLATE.format(
        country=settings["country"],
        state=settings["state"],
        locality=settings["locality"],
        organization=settings["organization"],
        organizational_unit=settings["organizational_unit"],
    )
    with open(config_path, "w", encoding="utf-8") as f:
        f.write(config_content)

    print(f"Generating CA certificate (valid {settings['validity_days']} days)...")
    run_openssl(
        settings["openssl_bin"],
        "req", "-new", "-x509",
        "-days", str(settings["validity_days"]),
        "-key", str(ca_key),
        "-out", str(ca_cert),
        "-config", str(config_path),
    )

    # Cleanup temporary config
    config_path.unlink()

    print(f"\nCA created successfully:")
    print(f"  Key:  {ca_key}")
    print(f"  Cert: {ca_cert}")

    return str(ca_key.relative_to(base_dir)), str(ca_cert.relative_to(base_dir))


def verify_openssl(repo_root: Path) -> bool:
    """
    Verify that OpenSSL is available and functional.

    Reads the openssl_bin path from s-certificate config.
    """
    settings = load_ca_settings(repo_root)
    openssl_bin = settings["openssl_bin"]

    try:
        result = subprocess.run(
            [openssl_bin, "version"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            print(f"OpenSSL version: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        pass

    print(f"ERROR: OpenSSL not found at {openssl_bin}")
    return False
