#!/bin/bash
set -e  # Exit on error
#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"
#######################################
# Get Terraform Outputs
#######################################
export MCN_CE_EU_CENTRAL1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')
#######################################
# Generate Payloads from Templates
#######################################
echo "Generating payload files from templates..."
envsubst < "${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/etc/__template_ew_loadbalancing-eu-central.json" \
         > "${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/payload_final_eu-central.json"
envsubst < "${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/etc/__template_ew_loadbalancing-eu-west.json" \
         > "${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/payload_final_eu-west.json"
#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer in EU-WEST..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' \
    -d @"${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/payload_final_eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"
echo "Creating load balancer in EU-CENTRAL..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' \
    -d @"${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE/payload_final_eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"
echo "Done!"