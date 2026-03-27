"""AWS credentials management."""

import configparser
import os
import sys
from pathlib import Path

from setup_init.config import AWSConfig


def get_credentials_path() -> Path:
    """Return the path to ~/.aws/credentials."""
    return Path.home() / ".aws" / "credentials"


def ensure_aws_directory() -> None:
    """Create ~/.aws directory if it doesn't exist."""
    aws_dir = Path.home() / ".aws"
    if not aws_dir.exists():
        print("Creating ~/.aws directory...")
        aws_dir.mkdir(mode=0o700)


def update_aws_credentials(aws_config: AWSConfig) -> None:
    """
    Update AWS credentials file with values from config.

    Creates the credentials file and directory if they don't exist.
    Handles both static credentials and STS temporary credentials.
    """
    ensure_aws_directory()

    credentials_path = get_credentials_path()
    profile = aws_config.auth_profile

    # Load existing credentials file or create new
    config = configparser.RawConfigParser()
    if credentials_path.exists():
        config.read(credentials_path)

    # Create or update profile section
    if not config.has_section(profile):
        print(f"Creating AWS profile [{profile}]...")
        config.add_section(profile)
    else:
        print(f"Updating AWS profile [{profile}]...")

    # Set credentials
    config.set(profile, "aws_access_key_id", aws_config.aws_access_key_id)
    config.set(profile, "aws_secret_access_key", aws_config.aws_secret_access_key)

    # Handle STS session token
    if aws_config.tmp_aws_cred:
        print("  Using STS temporary credentials")
        config.set(profile, "aws_session_token", aws_config.aws_session_token)
    elif config.has_option(profile, "aws_session_token"):
        # Remove session token if switching from STS to static
        config.remove_option(profile, "aws_session_token")

    # Write credentials file with secure permissions
    with open(credentials_path, "w", encoding="utf-8") as f:
        config.write(f)

    # Set secure file permissions (owner read/write only)
    os.chmod(credentials_path, 0o600)

    print(f"  Credentials written to {credentials_path}")
