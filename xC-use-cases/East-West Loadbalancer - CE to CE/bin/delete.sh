#!/bin/bash
set -e  # Exit on error
#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/East-West Loadbalancer - CE to CE"

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-api-int-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-api-int-west"
echo "Deleting load balancer: lb-api-int-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-api-int-central"

rm -f "${USE_CASE_DIR}/payload_final_eu-central.json"
rm -f "${USE_CASE_DIR}/payload_final_eu-west.json"