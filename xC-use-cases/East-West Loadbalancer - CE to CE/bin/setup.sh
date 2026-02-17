#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

#######################################
# Generate Payloads from Templates
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template_ew_loadbalancing-eu-central.json" > "${USE_CASE_DIR}/payload_final_eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_ew_loadbalancing-eu-west.json" > "${USE_CASE_DIR}/payload_final_eu-west.json"

#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer: lb-api-int-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-api-int-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
