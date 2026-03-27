"""Configuration loader and validation."""

import os
import sys
from dataclasses import dataclass, field

import yaml


@dataclass
class DistinguishedName:
    """CSR distinguished name fields."""

    country: str = "XX"
    state: str = "State"
    locality: str = "City"
    organization: str = "Org"
    organizational_unit: str = "Unit"
    email: str = "admin@example.com"


@dataclass
class CAConfig:
    """CA generation settings."""

    key_size: int = 4096
    validity_days: int = 3650

    # Distinguished name for the CA certificate (defaults to cert DN if not set)
    dn: DistinguishedName | None = None


@dataclass
class CertConfig:
    """Certificate generation settings."""

    openssl_bin: str = "/usr/bin/openssl"
    key_size: int = 2048
    validity_days: int = 365
    ca_cert: str = "ca/ca.cer"
    ca_key: str = "ca/ca.key"
    output_dir: str = "domains"
    p12_password: str = ""
    dn: DistinguishedName = field(default_factory=DistinguishedName)
    ca: CAConfig = field(default_factory=CAConfig)


@dataclass
class ClientCertConfig:
    """Client certificate generation settings for mTLS."""

    key_size: int = 2048
    validity_days: int = 365
    output_dir: str = "domains"
    dn: DistinguishedName = field(default_factory=DistinguishedName)


XC_BASE_URL = "https://{tenant}.console.ves.volterra.io"
XC_API_ENDPOINT = "/api/config/namespaces/{namespace}/certificates"


@dataclass
class XCConfig:
    """F5 Distributed Cloud upload settings."""

    tenant: str = ""
    api_token: str = ""
    namespace: str = "default"
    cert_name_prefix: str = "lab-cert"
    cert_description: str = "Auto-generated server certificate for %s"

    @property
    def base_url(self) -> str:
        return XC_BASE_URL.format(tenant=self.tenant)

    @property
    def endpoint(self) -> str:
        return XC_API_ENDPOINT.format(namespace=self.namespace)

    def __repr__(self) -> str:
        """Redact the API token in repr output."""
        token_display = self.api_token[:4] + "..." if self.api_token else "(empty)"
        return (
            f"XCConfig(tenant={self.tenant!r}, api_token={token_display!r}, "
            f"namespace={self.namespace!r})"
        )


def load_config(config_path: str) -> dict:
    """Load and return the YAML config, or exit with an error."""
    if not os.path.isfile(config_path):
        print(f"Error: Config file not found: {config_path}")
        print("Copy config/config.yaml.example to config/config.yaml and fill in your values.")
        sys.exit(1)

    with open(config_path, encoding="utf-8") as fh:
        cfg = yaml.safe_load(fh)

    if not cfg:
        print(f"Error: Config file is empty: {config_path}")
        sys.exit(1)

    return cfg


def load_project_config(project_config_path: str) -> dict:
    """
    Load the project-level config.yaml (setup-init/config.yaml).

    Extracts CA paths and certificate output directory. Returns a dict
    with keys: ca_cert, ca_key, cert_dir. All paths are resolved
    relative to the project config file's parent directory.
    """
    if not os.path.isfile(project_config_path):
        print(f"Error: Project config not found: {project_config_path}")
        print("Run './setup-init/bin/initialize.sh init' first to generate the CA.")
        sys.exit(1)

    with open(project_config_path, encoding="utf-8") as fh:
        cfg = yaml.safe_load(fh)

    if not cfg:
        print(f"Error: Project config is empty: {project_config_path}")
        sys.exit(1)

    cert_data = cfg.get("cert", {})
    config_dir = os.path.dirname(os.path.abspath(project_config_path))

    result = {}

    # Resolve CA paths (relative to project config directory)
    ca_key = cert_data.get("ca_key", "")
    ca_cert = cert_data.get("ca_cert", "")
    cert_dir = cert_data.get("cert_dir", ".cert/domains")

    if ca_key:
        result["ca_key"] = os.path.join(config_dir, ca_key)
    if ca_cert:
        result["ca_cert"] = os.path.join(config_dir, ca_cert)
    if cert_dir:
        result["cert_dir"] = os.path.join(config_dir, cert_dir)

    return result


def parse_cert_config(cfg: dict, project_paths: dict | None = None) -> CertConfig:
    """
    Extract certificate generation settings from config dict.

    Args:
        cfg: Tool-level config (certificate OpenSSL settings, DN, etc.)
        project_paths: Optional dict from load_project_config() with
                       absolute paths for ca_cert, ca_key, cert_dir.
                       When provided, these override the tool-level paths.
    """
    cert = cfg.get("certificate", {})
    dn_raw = cert.get("distinguished_name", {})
    ca_raw = cert.get("ca", {})
    ca_dn_raw = ca_raw.get("distinguished_name", {})

    dn = DistinguishedName(
        country=dn_raw.get("country", "XX"),
        state=dn_raw.get("state", "State"),
        locality=dn_raw.get("locality", "City"),
        organization=dn_raw.get("organization", "Org"),
        organizational_unit=dn_raw.get("organizational_unit", "Unit"),
        email=dn_raw.get("email", "admin@example.com"),
    )

    # CA DN: use explicit ca.distinguished_name if set, otherwise fall back to cert DN
    ca_dn: DistinguishedName | None = None
    if ca_dn_raw:
        ca_dn = DistinguishedName(
            country=ca_dn_raw.get("country", dn.country),
            state=ca_dn_raw.get("state", dn.state),
            locality=ca_dn_raw.get("locality", dn.locality),
            organization=ca_dn_raw.get("organization", dn.organization),
            organizational_unit=ca_dn_raw.get("organizational_unit", dn.organizational_unit),
            email=ca_dn_raw.get("email", dn.email),
        )

    # Determine paths: project config takes precedence over tool config
    if project_paths:
        ca_cert = project_paths.get("ca_cert", cert.get("ca_cert", "ca/ca.cer"))
        ca_key = project_paths.get("ca_key", cert.get("ca_key", "ca/ca.key"))
        output_dir = project_paths.get("cert_dir", cert.get("output_dir", "domains"))
    else:
        ca_cert = cert.get("ca_cert", "ca/ca.cer")
        ca_key = cert.get("ca_key", "ca/ca.key")
        output_dir = cert.get("output_dir", "domains")

    return CertConfig(
        openssl_bin=cert.get("openssl_bin", "/usr/bin/openssl"),
        key_size=cert.get("key_size", 2048),
        validity_days=cert.get("validity_days", 365),
        ca_cert=ca_cert,
        ca_key=ca_key,
        output_dir=output_dir,
        p12_password=cert.get("p12_password", ""),
        dn=dn,
        ca=CAConfig(
            key_size=ca_raw.get("key_size", 4096),
            validity_days=ca_raw.get("validity_days", 3650),
            dn=ca_dn,
        ),
    )


def parse_client_cert_config(
    cfg: dict, cert_cfg: CertConfig, project_paths: dict | None = None,
) -> ClientCertConfig:
    """Extract client certificate settings from config dict.

    Falls back to the server certificate settings (cert_cfg) for any
    missing fields. If the entire client_certificate section is absent,
    all values are derived from cert_cfg.

    When project_paths is provided, cert_dir overrides the output_dir.
    """
    client = cfg.get("client_certificate", {})
    dn_raw = client.get("distinguished_name", {})
    base_dn = cert_cfg.dn

    dn = DistinguishedName(
        country=dn_raw.get("country", base_dn.country),
        state=dn_raw.get("state", base_dn.state),
        locality=dn_raw.get("locality", base_dn.locality),
        organization=dn_raw.get("organization", base_dn.organization),
        organizational_unit=dn_raw.get("organizational_unit", base_dn.organizational_unit),
        email=dn_raw.get("email", base_dn.email),
    )

    # Project cert_dir overrides tool-level output_dir
    if project_paths and "cert_dir" in project_paths:
        output_dir = project_paths["cert_dir"]
    else:
        output_dir = client.get("output_dir", cert_cfg.output_dir)

    return ClientCertConfig(
        key_size=client.get("key_size", cert_cfg.key_size),
        validity_days=client.get("validity_days", cert_cfg.validity_days),
        output_dir=output_dir,
        dn=dn,
    )


def parse_xc_config(cfg: dict) -> XCConfig:
    """Extract and validate XC upload settings from config dict."""
    xc = cfg.get("xc", {})

    xc_cfg = XCConfig(
        tenant=xc.get("tenant", ""),
        api_token=xc.get("api_token", ""),
        namespace=xc.get("namespace", "default"),
        cert_name_prefix=xc.get("cert_name_prefix", "lab-cert"),
        cert_description=xc.get("cert_description", "Auto-generated server certificate for %s"),
    )

    if not xc_cfg.tenant or xc_cfg.tenant == "your-tenant-name":
        print("Error: XC tenant name not configured in config.yaml.")
        sys.exit(1)

    if not xc_cfg.api_token or "REPLACE" in xc_cfg.api_token:
        print("Error: XC API token not configured in config.yaml.")
        sys.exit(1)

    return xc_cfg
