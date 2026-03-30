"""CLI entry point and orchestration for the setup process."""

import argparse
import os
import sys
from pathlib import Path

from setup_init import __version__
from setup_init.config import display_config_summary, load_config, save_config, validate_config


# Directory layout
BASE_DIR = Path(__file__).resolve().parent.parent.parent  # setup-init/
ROOT_DIR = BASE_DIR.parent                                 # repo root
INFRASTRUCTURE_DIR = ROOT_DIR / "infrastructure"
CONFIG_FILE = BASE_DIR / "config.yaml"


def cmd_init(args: argparse.Namespace) -> int:
    """Full initialization: config, CA, AWS credentials, xC certs, Terraform."""
    from setup_init.aws import update_aws_credentials
    from setup_init.ca import generate_ca, verify_openssl
    from setup_init.network import get_public_ip_cidr
    from setup_init.terraform import (
        terraform_apply,
        terraform_fmt,
        terraform_init,
        terraform_plan,
        verify_terraform,
    )
    from setup_init.xc import convert_p12_to_pem, fetch_tenant_anycast_ip

    print("=" * 60)
    print(f"  xC MCN Demo Lab — Initialization v{__version__}")
    print("=" * 60)

    # Step 0: Verify prerequisites
    print("\n--- Checking prerequisites ---")
    config = load_config(CONFIG_FILE)

    errors = validate_config(config)
    if errors:
        print("\nConfiguration errors:")
        for error in errors:
            print(f"  - {error}")
        print(f"\nPlease fix {CONFIG_FILE} and try again.")
        return 1

    if not verify_openssl(ROOT_DIR):
        return 1
    if not verify_terraform():
        return 1

    # Step 1: Detect public IP
    print("\n--- Detecting public IP ---")
    try:
        ip_cidr = get_public_ip_cidr()
        config.student.ip_address = ip_cidr
        print(f"  Public IP: {ip_cidr}")
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 1

    # Step 2: Generate CA (reads OpenSSL settings from s-certificate config)
    print("\n--- Certificate Authority ---")
    ca_key_path, ca_cert_path = generate_ca(config.cert, BASE_DIR, ROOT_DIR)
    config.cert.ca_key = ca_key_path
    config.cert.ca_cert = ca_cert_path

    # Step 3: Update AWS credentials
    print("\n--- AWS Credentials ---")
    update_aws_credentials(config.aws)

    # Step 4: Convert xC P12 to PEM
    print("\n--- xC Certificate ---")
    try:
        convert_p12_to_pem(config.xc, BASE_DIR)
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 1

    # Step 5: Resolve tenant Anycast IP
    print("\n--- Tenant Anycast IP ---")
    anycast_ip = fetch_tenant_anycast_ip(config.xc, BASE_DIR)
    if anycast_ip:
        config.xc.tenant_anycast_ip = anycast_ip
    else:
        print("  WARNING: Could not resolve Anycast IP (non-fatal, continuing)")

    # Step 6: Show summary and confirm before deployment
    if not display_config_summary(config):
        print("\nAborted by user.")
        return 1

    # Step 7: Save config with all auto-populated values
    print("\n--- Saving configuration ---")
    save_config(config, CONFIG_FILE)
    print(f"  Config written to {CONFIG_FILE}")

    # Step 8: Terraform deployment
    print("\n--- Terraform Deployment ---")
    tf_env = {"VES_P12_PASSWORD": config.xc.p12_pwd}

    try:
        terraform_fmt(INFRASTRUCTURE_DIR)
        terraform_init(INFRASTRUCTURE_DIR, env=tf_env)
        terraform_plan(INFRASTRUCTURE_DIR, env=tf_env)
        terraform_apply(INFRASTRUCTURE_DIR, auto_approve=True, env=tf_env)
    except RuntimeError as e:
        print(f"\nERROR: {e}")
        print("Terraform deployment failed. Check the output above for details.")
        return 1

    print("\n" + "=" * 60)
    print("  Initialization complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("  1. Wait for xC Gateways to come online (~15-20 min)")
    print("  2. Add /etc/hosts entries:")
    print(f'     terraform -chdir="{INFRASTRUCTURE_DIR}" output -raw etc-hosts')
    print("  3. Open SSH sessions:")
    print(f"     {BASE_DIR}/.ssh/ssh-key-permission_lnx.sh all")

    return 0


def cmd_update_creds(args: argparse.Namespace) -> int:
    """Update AWS credentials only (no Terraform, no CA)."""
    from setup_init.aws import update_aws_credentials

    print("--- Updating AWS Credentials ---")

    config = load_config(CONFIG_FILE)
    update_aws_credentials(config.aws)

    print("\nAWS credentials updated successfully.")
    return 0


def cmd_update_ip(args: argparse.Namespace) -> int:
    """Update public IP in config and refresh Security Groups via Terraform."""
    from setup_init.network import get_public_ip_cidr
    from setup_init.terraform import terraform_apply, terraform_init

    print("--- Updating Public IP ---")

    config = load_config(CONFIG_FILE)
    old_ip = config.student.ip_address

    try:
        new_ip = get_public_ip_cidr()
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 1

    if old_ip == new_ip:
        print(f"  IP unchanged: {new_ip}")
        print("  Nothing to do.")
        return 0

    print(f"  Old IP: {old_ip or '(not set)'}")
    print(f"  New IP: {new_ip}")

    config.student.ip_address = new_ip
    save_config(config, CONFIG_FILE)
    print(f"  Config updated: {CONFIG_FILE}")

    # Targeted Terraform apply — only Security Groups (dynamic resources)
    # BIG-IP user-data and EC2 instances are NOT affected (would require re-deploy)
    print("\n--- Applying IP change to Security Groups ---")
    tf_env = {"VES_P12_PASSWORD": config.xc.p12_pwd}

    try:
        terraform_init(INFRASTRUCTURE_DIR, env=tf_env)
        # Target all security groups in both region modules
        terraform_apply(
            INFRASTRUCTURE_DIR,
            env=tf_env,
            extra_args=[
                "-target=module.eu-central-1.aws_security_group.xC-mcn-server-allow-ubuntu",
                "-target=module.eu-central-1.aws_security_group.xC-mcn-server-allow-bigip",
                "-target=module.eu-central-1.aws_security_group.xC-mcn-site-allow-ubuntu",
                "-target=module.eu-west-1.aws_security_group.xC-mcn-server-allow-ubuntu",
                "-target=module.eu-west-1.aws_security_group.xC-mcn-server-allow-bigip",
                "-target=module.eu-west-1.aws_security_group.xC-mcn-site-allow-ubuntu",
            ],
        )
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 1

    print(f"\nIP updated successfully: {old_ip} → {new_ip}")
    print("NOTE: BIG-IP user-data still references the old IP. This only affects")
    print("      the BIG-IP AS3 config (if student_ip is used there). Security")
    print("      Groups are updated and effective immediately.")
    return 0


def cmd_generate_ca(args: argparse.Namespace) -> int:
    """Generate CA certificate only (no Terraform, no AWS)."""
    from setup_init.ca import generate_ca, verify_openssl

    print("--- Generating Certificate Authority ---")

    config = load_config(CONFIG_FILE)

    if not verify_openssl(ROOT_DIR):
        return 1

    ca_key_path, ca_cert_path = generate_ca(config.cert, BASE_DIR, ROOT_DIR)
    config.cert.ca_key = ca_key_path
    config.cert.ca_cert = ca_cert_path

    # Save CA paths to config
    save_config(config, CONFIG_FILE)
    print(f"\nCA paths written to {CONFIG_FILE}")

    return 0


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI argument parser."""
    parser = argparse.ArgumentParser(
        prog="setup_init",
        description="xC MCN Demo Lab — Setup and Initialization",
    )
    parser.add_argument(
        "--version", action="version", version=f"%(prog)s {__version__}",
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # init command
    init_parser = subparsers.add_parser(
        "init",
        help="Full initialization: CA, AWS, xC certs, Terraform deployment",
    )
    init_parser.set_defaults(func=cmd_init)

    # update-creds command
    creds_parser = subparsers.add_parser(
        "update-creds",
        help="Update AWS credentials only (after STS rotation)",
    )
    creds_parser.set_defaults(func=cmd_update_creds)

    # update-ip command
    ip_parser = subparsers.add_parser(
        "update-ip",
        help="Update public IP in config and refresh Security Groups",
    )
    ip_parser.set_defaults(func=cmd_update_ip)

    # generate-ca command
    ca_parser = subparsers.add_parser(
        "generate-ca",
        help="Generate Certificate Authority only",
    )
    ca_parser.set_defaults(func=cmd_generate_ca)

    return parser


def main() -> None:
    """Main entry point."""
    parser = build_parser()
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(0)

    exit_code = args.func(args)
    sys.exit(exit_code)
