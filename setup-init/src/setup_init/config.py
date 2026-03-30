"""Configuration loading and validation for the setup process."""

import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


@dataclass
class AWSConfig:
    """AWS authentication configuration."""

    auth_profile: str
    aws_access_key_id: str
    aws_secret_access_key: str
    aws_session_token: str
    region_site_1: str
    region_site_2: str
    tmp_aws_cred: bool


@dataclass
class StudentConfig:
    """Student/operator identity configuration."""

    name: str
    email: str
    ip_address: str = ""


@dataclass
class XCConfig:
    """F5 Distributed Cloud configuration."""

    p12_auth: str
    p12_pwd: str
    tenant: str
    tenant_shrt: str
    tenant_api: str
    namespace: str
    tenant_anycast_ip: str = ""


@dataclass
class CertPaths:
    """Certificate path configuration (where things are stored)."""

    ca_dir: str = ".cert/ca"
    cert_dir: str = ".cert/domains"
    # Paths are populated after CA generation
    ca_key: str = ""
    ca_cert: str = ""


@dataclass
class Config:
    """Complete configuration for the setup process."""

    aws: AWSConfig
    student: StudentConfig
    xc: XCConfig
    cert: CertPaths
    f5_password: str
    raw: dict = field(default_factory=dict)  # Original YAML data for write-back


def load_config(config_path: Path) -> Config:
    """
    Load and validate configuration from YAML file.

    Exits with error message if file is missing or invalid.
    """
    if not config_path.exists():
        print(f"ERROR: Config file not found: {config_path}")
        print(f"HINT: Copy template/config.yaml to {config_path.name} and fill in your values")
        sys.exit(1)

    try:
        with open(config_path, encoding="utf-8") as f:
            data = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"ERROR: Invalid YAML in {config_path}: {e}")
        sys.exit(1)

    # Parse AWS config — environment variables override file values
    aws_data = data.get("aws", {})
    aws_key = os.environ.get("AWS_ACCESS_KEY_ID", "") or aws_data.get("aws_access_key_id", "")
    aws_secret = os.environ.get("AWS_SECRET_ACCESS_KEY", "") or aws_data.get("aws_secret_access_key", "")
    aws_token = os.environ.get("AWS_SESSION_TOKEN", "") or aws_data.get("aws_session_token", "")

    # STS auto-detect: if session token is present, assume STS
    # Explicit config value overrides auto-detection
    explicit_tmp = aws_data.get("tmp_aws_cred", None)
    if explicit_tmp is not None:
        is_sts = bool(explicit_tmp)
    else:
        is_sts = bool(aws_token and "<" not in aws_token)

    aws = AWSConfig(
        auth_profile=aws_data.get("auth_profile", "xc-mcn-lab"),
        aws_access_key_id=aws_key,
        aws_secret_access_key=aws_secret,
        aws_session_token=aws_token,
        region_site_1=aws_data.get("region_site_1", "eu-central-1"),
        region_site_2=aws_data.get("region_site_2", "eu-west-1"),
        tmp_aws_cred=is_sts,
    )

    # Parse student config
    student_data = data.get("student", {})
    student = StudentConfig(
        name=student_data.get("name", ""),
        email=student_data.get("email", ""),
        ip_address=student_data.get("ip-address", ""),
    )

    # Parse xC config — derive tenant_api and tenant_shrt from tenant if not set
    xc_data = data.get("xC", {})
    tenant = xc_data.get("tenant", "")
    tenant_shrt = xc_data.get("tenant_shrt", "")
    tenant_api = xc_data.get("tenant_api", "")

    # Auto-derive tenant_shrt: drop the last segment (hash) from tenant name
    # e.g. "f5-emea-ent-bceuutam" -> "f5-emea-ent"
    # e.g. "volt-field-vhptnhxg" -> "volt-field"
    if tenant and (not tenant_shrt or "<" in tenant_shrt):
        parts = tenant.rsplit("-", 1)
        tenant_shrt = parts[0] if len(parts) > 1 else tenant

    # Auto-derive tenant_api from tenant_shrt (not full tenant name)
    # e.g. "volt-field" -> "https://volt-field.console.ves.volterra.io/api"
    if tenant and (not tenant_api or "<" in tenant_api):
        shrt = tenant_shrt or tenant.rsplit("-", 1)[0]
        tenant_api = f"https://{shrt}.console.ves.volterra.io/api"

    # P12 auto-detect: scan .xC/ directory if p12_auth is not manually set
    p12_auth = xc_data.get("p12_auth", "")
    if not p12_auth or "<" in p12_auth:
        p12_auth = _auto_detect_p12(config_path.parent, tenant)

    xc = XCConfig(
        p12_auth=p12_auth,
        p12_pwd=xc_data.get("p_12_pwd", ""),
        tenant=tenant,
        tenant_shrt=tenant_shrt,
        tenant_api=tenant_api,
        namespace=xc_data.get("namespace", ""),
        tenant_anycast_ip=xc_data.get("tenant_anycast_ip", ""),
    )

    # Parse cert paths
    cert_data = data.get("cert", {})
    cert = CertPaths(
        ca_dir=cert_data.get("ca_dir", ".cert/ca"),
        cert_dir=cert_data.get("cert_dir", ".cert/domains"),
        ca_key=cert_data.get("ca_key", ""),
        ca_cert=cert_data.get("ca_cert", ""),
    )

    # Parse other values
    f5_data = data.get("f5", {})

    return Config(
        aws=aws,
        student=student,
        xc=xc,
        cert=cert,
        f5_password=f5_data.get("f5_password", ""),
        raw=data,
    )


def _auto_detect_p12(base_dir: Path, tenant: str) -> str:
    """
    Auto-detect P12 certificate file in the .xC/ directory.

    Priority:
    1. If tenant is set: files containing the tenant string, newest first
    2. If only one .p12 file exists: use it regardless of name
    3. No match: return empty string
    """
    xc_dir = base_dir / ".xC"
    if not xc_dir.is_dir():
        return ""

    p12_files = sorted(xc_dir.glob("*.p12"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not p12_files:
        return ""

    # Filter by tenant name if available
    if tenant and "<" not in tenant:
        # Try tenant_shrt (first part) for matching — P12 files use short name
        tenant_shrt = tenant.rsplit("-", 1)[0] if "-" in tenant else tenant
        matches = [f for f in p12_files if tenant_shrt in f.name]
        if matches:
            return f".xC/{matches[0].name}"

    # Fallback: if exactly one P12 file, use it
    if len(p12_files) == 1:
        return f".xC/{p12_files[0].name}"

    return ""


def display_config_summary(config: "Config") -> bool:
    """
    Display a formatted configuration summary and ask for confirmation.

    Returns True to proceed, False to abort.
    """
    COL = 22  # label column width

    os.system("clear")
    print("══════════════════════════════════════════════")
    print("  xC MCN Demo Lab — Configuration Summary")
    print("══════════════════════════════════════════════")
    print()

    # AWS
    print("  AWS")
    print("  ──────────────────────────────────────────")
    cred_ok = bool(
        config.aws.aws_access_key_id
        and "<" not in config.aws.aws_access_key_id
    )
    cred_source = ""
    if os.environ.get("AWS_ACCESS_KEY_ID"):
        cred_source = " (env var)"
    print(f"  {'Credentials':<{COL}} {'✓ loaded' + cred_source if cred_ok else '✗ missing'}")
    auth_type = "STS (temporary)" if config.aws.tmp_aws_cred else "Static (IAM)"
    print(f"  {'Auth Type':<{COL}} {auth_type}")
    print(f"  {'Profile':<{COL}} {config.aws.auth_profile}")
    print(f"  {'Region 1':<{COL}} {config.aws.region_site_1}")
    print(f"  {'Region 2':<{COL}} {config.aws.region_site_2}")
    print()

    # Student
    print("  Student")
    print("  ──────────────────────────────────────────")
    print(f"  {'Name':<{COL}} {config.student.name}")
    print(f"  {'Email':<{COL}} {config.student.email}")
    ip_display = config.student.ip_address or "(will be detected)"
    print(f"  {'Public IP':<{COL}} {ip_display}")
    print()

    # xC
    print("  F5 Distributed Cloud")
    print("  ──────────────────────────────────────────")
    print(f"  {'Tenant':<{COL}} {config.xc.tenant}")
    print(f"  {'Namespace':<{COL}} {config.xc.namespace}")
    # Show only filename, not full path
    p12_display = config.xc.p12_auth.split("/")[-1] if config.xc.p12_auth else "✗ not found"
    p12_auto = " (auto-detected)" if "<" not in (config.raw.get("xC", {}).get("p12_auth", "<")) == False else ""
    print(f"  {'P12 Certificate':<{COL}} {p12_display}")
    anycast = config.xc.tenant_anycast_ip or "(will be fetched)"
    print(f"  {'Anycast IP':<{COL}} {anycast}")
    print()

    print("══════════════════════════════════════════════")
    try:
        answer = input("  Proceed with these settings? [Y/n]: ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        return False

    return answer != "n"


def save_config(config: Config, config_path: Path) -> None:
    """
    Save configuration back to YAML file.

    Updates the raw data with current values and writes to disk.
    """
    data = config.raw.copy()

    # Update student IP
    if "student" not in data:
        data["student"] = {}
    data["student"]["ip-address"] = config.student.ip_address

    # Update cert paths if CA was generated
    if config.cert.ca_key or config.cert.ca_cert:
        if "cert" not in data:
            data["cert"] = {}
        data["cert"]["ca_key"] = config.cert.ca_key
        data["cert"]["ca_cert"] = config.cert.ca_cert
        data["cert"]["ca_dir"] = config.cert.ca_dir
        data["cert"]["cert_dir"] = config.cert.cert_dir

    # Update xC config (auto-derived + resolved values)
    if "xC" not in data:
        data["xC"] = {}
    if config.xc.tenant_anycast_ip:
        data["xC"]["tenant_anycast_ip"] = config.xc.tenant_anycast_ip
    if config.xc.p12_auth:
        data["xC"]["p12_auth"] = config.xc.p12_auth
    if config.xc.tenant_shrt:
        data["xC"]["tenant_shrt"] = config.xc.tenant_shrt
    if config.xc.tenant_api:
        data["xC"]["tenant_api"] = config.xc.tenant_api

    # Update AWS credentials (persist env var overrides to file)
    if "aws" not in data:
        data["aws"] = {}
    data["aws"]["aws_access_key_id"] = config.aws.aws_access_key_id
    data["aws"]["aws_secret_access_key"] = config.aws.aws_secret_access_key
    data["aws"]["aws_session_token"] = config.aws.aws_session_token

    with open(config_path, "w", encoding="utf-8") as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)


def validate_config(config: Config) -> list[str]:
    """
    Validate configuration values.

    Returns a list of error messages (empty if valid).
    """
    errors = []

    # AWS validation
    if not config.aws.aws_access_key_id or "<" in config.aws.aws_access_key_id:
        errors.append("aws.aws_access_key_id is required (set in config or AWS_ACCESS_KEY_ID env var)")
    if not config.aws.aws_secret_access_key or "<" in config.aws.aws_secret_access_key:
        errors.append("aws.aws_secret_access_key is required (set in config or AWS_SECRET_ACCESS_KEY env var)")
    if config.aws.tmp_aws_cred and (not config.aws.aws_session_token or "<" in config.aws.aws_session_token):
        errors.append("aws.aws_session_token is required for STS credentials (set in config or AWS_SESSION_TOKEN env var)")

    # Student validation
    student_name = config.student.name
    student_name_max_length = 16
    student_name_pattern = re.compile(r"^[a-z0-9](?:[a-z0-9-]{0,14}[a-z0-9])?$")

    if not student_name or "<" in student_name:
        errors.append("student.name is required")
    else:
        if len(student_name) > student_name_max_length:
            errors.append(f"student.name must be <= {student_name_max_length} characters")
        if not student_name_pattern.match(student_name):
            errors.append(
                "student.name must be lowercase alphanumeric or hyphen, "
                "start/end with alphanumeric"
            )
    if not config.student.email or "<" in config.student.email:
        errors.append("student.email is required")

    # xC validation
    if not config.xc.p12_auth or "<" in config.xc.p12_auth:
        errors.append("xC.p12_auth: no P12 certificate found (place .p12 file in setup-init/.xC/ or set path in config)")
    if not config.xc.p12_pwd or "<" in config.xc.p12_pwd:
        errors.append("xC.p_12_pwd is required")
    if not config.xc.tenant or "<" in config.xc.tenant:
        errors.append("xC.tenant is required")

    return errors
