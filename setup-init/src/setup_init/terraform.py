"""Terraform execution wrapper with proper error handling."""

import os
import subprocess
import sys
from pathlib import Path


def run_terraform(
    command: str,
    working_dir: Path,
    *args: str,
    env: dict | None = None,
    capture: bool = False,
) -> subprocess.CompletedProcess:
    """
    Run a Terraform command with error handling.

    Args:
        command: Terraform subcommand (init, plan, apply, destroy, etc.)
        working_dir: Directory containing Terraform configuration
        *args: Additional arguments for the command
        env: Additional environment variables
        capture: Whether to capture output (default: stream to terminal)

    Returns:
        CompletedProcess with return code

    Raises:
        RuntimeError: If the command fails
    """
    cmdline = ["terraform", f"-chdir={working_dir}", command, *args]

    # Merge environment
    full_env = os.environ.copy()
    if env:
        full_env.update(env)

    print(f"\n{'=' * 60}")
    print(f"Running: {' '.join(cmdline)}")
    print(f"{'=' * 60}\n")

    result = subprocess.run(
        cmdline,
        env=full_env,
        capture_output=capture,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Terraform {command} failed with exit code {result.returncode}"
        )

    return result


def terraform_fmt(working_dir: Path) -> None:
    """Format Terraform files."""
    run_terraform("fmt", working_dir)


def terraform_init(working_dir: Path, env: dict | None = None) -> None:
    """Initialize Terraform working directory."""
    run_terraform("init", working_dir, env=env)


def terraform_plan(
    working_dir: Path,
    plan_file: Path | None = None,
    env: dict | None = None,
) -> None:
    """
    Create Terraform execution plan.

    Args:
        working_dir: Terraform configuration directory
        plan_file: Optional path to save plan file
        env: Additional environment variables
    """
    args = []
    if plan_file:
        args.append(f"-out={plan_file}")

    run_terraform("plan", working_dir, *args, env=env)


def terraform_apply(
    working_dir: Path,
    plan_file: Path | None = None,
    auto_approve: bool = False,
    env: dict | None = None,
) -> None:
    """
    Apply Terraform changes.

    Args:
        working_dir: Terraform configuration directory
        plan_file: Optional saved plan file to apply
        auto_approve: Skip interactive approval
        env: Additional environment variables
    """
    args = []
    if auto_approve:
        args.append("-auto-approve")
    if plan_file:
        args.append(str(plan_file))

    run_terraform("apply", working_dir, *args, env=env)


def terraform_destroy(
    working_dir: Path,
    auto_approve: bool = False,
    env: dict | None = None,
) -> None:
    """
    Destroy Terraform-managed infrastructure.

    Args:
        working_dir: Terraform configuration directory
        auto_approve: Skip interactive approval
        env: Additional environment variables
    """
    args = []
    if auto_approve:
        args.append("-auto-approve")

    run_terraform("destroy", working_dir, *args, env=env)


def verify_terraform() -> bool:
    """
    Verify that Terraform is available.

    Returns True if Terraform is installed.
    """
    try:
        result = subprocess.run(
            ["terraform", "version"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            # Extract first line (version info)
            version = result.stdout.strip().split("\n")[0]
            print(f"Terraform version: {version}")
            return True
    except FileNotFoundError:
        pass

    print("ERROR: Terraform not found. Please install Terraform >= 1.0")
    return False
