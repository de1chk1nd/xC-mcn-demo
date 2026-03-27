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

    # Parse AWS config
    aws_data = data.get("aws", {})
    aws = AWSConfig(
        auth_profile=aws_data.get("auth_profile", "terraform"),
        aws_access_key_id=aws_data.get("aws_access_key_id", ""),
        aws_secret_access_key=aws_data.get("aws_secret_access_key", ""),
        aws_session_token=aws_data.get("aws_session_token", ""),
        region_site_1=aws_data.get("region_site_1", "eu-central-1"),
        region_site_2=aws_data.get("region_site_2", "eu-west-1"),
        tmp_aws_cred=aws_data.get("tmp_aws_cred", True),
    )

    # Parse student config
    student_data = data.get("student", {})
    student = StudentConfig(
        name=student_data.get("name", ""),
        email=student_data.get("email", ""),
        ip_address=student_data.get("ip-address", ""),
    )

    # Parse xC config
    xc_data = data.get("xC", {})
    xc = XCConfig(
        p12_auth=xc_data.get("p12_auth", ""),
        p12_pwd=xc_data.get("p_12_pwd", ""),
        tenant=xc_data.get("tenant", ""),
        tenant_shrt=xc_data.get("tenant_shrt", ""),
        tenant_api=xc_data.get("tenant_api", ""),
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

    # Update xC tenant anycast IP if resolved
    if config.xc.tenant_anycast_ip:
        if "xC" not in data:
            data["xC"] = {}
        data["xC"]["tenant_anycast_ip"] = config.xc.tenant_anycast_ip

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
        errors.append("aws.aws_access_key_id is required")
    if not config.aws.aws_secret_access_key or "<" in config.aws.aws_secret_access_key:
        errors.append("aws.aws_secret_access_key is required")
    if config.aws.tmp_aws_cred and (not config.aws.aws_session_token or "<" in config.aws.aws_session_token):
        errors.append("aws.aws_session_token is required when tmp_aws_cred is true")

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
        errors.append("xC.p12_auth is required")
    if not config.xc.p12_pwd or "<" in config.xc.p12_pwd:
        errors.append("xC.p_12_pwd is required")
    if not config.xc.tenant or "<" in config.xc.tenant:
        errors.append("xC.tenant is required")

    return errors
