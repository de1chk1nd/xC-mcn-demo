#!/bin/bash
# Common Configuration Loader
# Usage: source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"
# Detect repo root if not set
if [ -z "${REPO_ROOT}" ]; then
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$REPO_ROOT" ]; then
        echo "ERROR: Not in a git repository"
        exit 1
    fi
    export REPO_ROOT
fi
# Config file path
CONFIG_FILE="${REPO_ROOT}/setup-init/config.yaml"
# Check prerequisites
if ! command -v yq &> /dev/null; then
    echo "ERROR: yq not installed"
    exit 1
fi
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: ${CONFIG_FILE}"
    exit 1
fi
# Load XC configuration
export P12_PASSWORD=$(yq '.xC.p_12_pwd' "$CONFIG_FILE")
export TENANT=$(yq '.xC.tenant_shrt' "$CONFIG_FILE")
export NAMESPACE=$(yq '.xC.namespace' "$CONFIG_FILE")
export CERT_FILE="${REPO_ROOT}/setup-init/.xC/xc-curl.crt.pem"
# Validate PEM certificate exists
if [ ! -f "$CERT_FILE" ]; then
    echo "ERROR: PEM certificate not found: ${CERT_FILE}"
    echo "HINT: Run 'python3 ${REPO_ROOT}/setup-init/initialize_infrastructure.py' first"
    exit 1
fi
echo "✓ Configuration loaded (using PEM certificate)"