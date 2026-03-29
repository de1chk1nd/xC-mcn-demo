#!/bin/bash
set -euo pipefail

# xC MCN Demo Lab — Teardown Script
# Destroys all Terraform-managed infrastructure and cleans up local artifacts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
SETUP_DIR="${REPO_ROOT}/setup-init"
CONFIG_FILE="${SETUP_DIR}/config.yaml"

# Check prerequisites
if ! command -v yq &> /dev/null; then
    echo "ERROR: yq not installed"
    exit 1
fi
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: ${CONFIG_FILE}"
    exit 1
fi

# Load configuration values
P12_PASSWORD=$(yq '.xC.p_12_pwd' "$CONFIG_FILE")
AUTH_PROFILE=$(yq '.aws.auth_profile' "$CONFIG_FILE")

echo "=============================================="
echo "  xC MCN Demo Lab — Teardown"
echo "=============================================="
echo ""
echo "WARNING: This will destroy all lab infrastructure"
echo "         and remove all generated certificates!"
echo ""

#######################################
# Step 1: Destroy Terraform infrastructure
#######################################
echo "--- Terraform Destroy ---"
export VES_P12_PASSWORD="${P12_PASSWORD}"
terraform -chdir="${REPO_ROOT}/infrastructure" destroy -auto-approve

#######################################
# Step 2: Remove generated certificates
#######################################
echo ""
echo "--- Cleaning up certificates ---"

# Remove xC PEM certificate
if [ -f "${SETUP_DIR}/.xC/xc-curl.crt.pem" ]; then
    rm -f "${SETUP_DIR}/.xC/xc-curl.crt.pem"
    echo "  Removed: .xC/xc-curl.crt.pem"
fi

# Remove CA and domain certificates
if [ -d "${SETUP_DIR}/.cert" ]; then
    rm -rf "${SETUP_DIR}/.cert"
    echo "  Removed: .cert/ (CA + domain certificates)"
fi

#######################################
# Step 3: Clean up AWS credentials profile
#######################################
echo ""
echo "--- Cleaning up AWS credentials ---"

AWS_CREDS="${HOME}/.aws/credentials"
if [ -f "$AWS_CREDS" ] && [ -n "$AUTH_PROFILE" ]; then
    if grep -q "\\[${AUTH_PROFILE}\\]" "$AWS_CREDS" 2>/dev/null; then
        # Remove the profile section using Python (reliable multi-line removal)
        python3 -c "
import configparser, sys
config = configparser.RawConfigParser()
config.read('${AWS_CREDS}')
if config.has_section('${AUTH_PROFILE}'):
    config.remove_section('${AUTH_PROFILE}')
    with open('${AWS_CREDS}', 'w') as f:
        config.write(f)
    print('  Removed AWS profile [${AUTH_PROFILE}] from ${AWS_CREDS}')
else:
    print('  AWS profile [${AUTH_PROFILE}] not found (already clean)')
"
    else
        echo "  AWS profile [${AUTH_PROFILE}] not found (already clean)"
    fi
else
    echo "  No AWS credentials file found (nothing to clean)"
fi

#######################################
# Step 4: Reset auto-populated config values
#######################################
echo ""
echo "--- Resetting config.yaml ---"

yq -i '.student."ip-address" = "<AUTO-POPULATED>"' "$CONFIG_FILE"
yq -i '.cert.ca_key = ""' "$CONFIG_FILE"
yq -i '.cert.ca_cert = ""' "$CONFIG_FILE"
yq -i '.xC.tenant_anycast_ip = ""' "$CONFIG_FILE"
yq -i '.xC.tenant_shrt = "<AUTO-DERIVED>"' "$CONFIG_FILE"
yq -i '.xC.tenant_api = "<AUTO-DERIVED>"' "$CONFIG_FILE"
echo "  Reset: student.ip-address, cert paths, xC.tenant_anycast_ip, xC.tenant_shrt, xC.tenant_api"

echo ""
echo "=============================================="
echo "  Teardown complete!"
echo "=============================================="
echo ""
echo "Remaining manual steps:"
echo "  - Remove local /etc/hosts entries: sudo vim /etc/hosts"
