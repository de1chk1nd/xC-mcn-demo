#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

#######################################
# Delete Infrastructure
#######################################
export VES_P12_PASSWORD="${P12_PASSWORD}"
rm -f "${REPO_ROOT}/setup-init/.xC/xc-curl.crt.pem"
terraform -chdir="${REPO_ROOT}/infrastructure" destroy -auto-approve
