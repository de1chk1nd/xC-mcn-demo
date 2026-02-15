#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE"

#######################################
# Get Terraform Outputs
#######################################
export UBUNTU_NLB_EU_CENTRAL=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-central-1 | tr -d '\"')
export UBUNTU_NLB_EU_WEST=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-west-1 | tr -d '\"')

#######################################
# Generate Payload from Template
#######################################
echo "Generating origin-pool.json from template..."
envsubst < "${USE_CASE_DIR}/etc/__template__origin-pool.json" > "${USE_CASE_DIR}/etc/origin-pool.json"

echo "Done!"
