#!/bin/bash
set -euo pipefail

# xC MCN Demo Lab — Initialization Wrapper
# Usage: ./setup-init/bin/initialize.sh [init|update-creds|generate-ca]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_INIT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="${SETUP_INIT_DIR}/src"

# Default command
COMMAND="${1:-init}"

# Set PYTHONPATH to find the setup_init package
export PYTHONPATH="${SRC_DIR}:${PYTHONPATH:-}"

# Run the Python module with the specified command
exec python3 -m setup_init "$COMMAND"
