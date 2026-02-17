#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE"

#######################################
# Delete Load Balancer
#######################################
echo "Deleting load balancer: lb-echo-public..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-echo-public"

#######################################
# Delete Origin Pool
#######################################
echo "Deleting origin pool: origin-public-echo-aws..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools/origin-public-echo-aws"

#######################################
# Cleanup generated files
#######################################
rm -f "${USE_CASE_DIR}"/payload_final_*.json

echo "Done!"
