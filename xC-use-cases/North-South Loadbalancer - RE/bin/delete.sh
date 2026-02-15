#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE"

#######################################
# Cleanup generated files
#######################################
echo "Removing generated origin-pool.json..."
rm -f "${USE_CASE_DIR}/etc/origin-pool.json"

echo "Done!"
