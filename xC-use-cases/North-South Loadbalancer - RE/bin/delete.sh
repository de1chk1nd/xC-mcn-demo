#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
TLS_CERT_NAME="tls-${STUDENT}-echo-public"
DOMAIN="echo-public.${STUDENT}.xc-mcn-lab.aws"
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"

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
# Delete Certificate
#######################################
echo "Deleting certificate: ${TLS_CERT_NAME}..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/certificates/${TLS_CERT_NAME}"

#######################################
# Cleanup generated files
#######################################
rm -f "${USE_CASE_DIR}"/payload_final_*.json
rm -f "${CERT_DIR}/${DOMAIN}.cert" "${CERT_DIR}/${DOMAIN}.key" 2>/dev/null
rm -f "${REPO_ROOT}/tools/s-certificate/config/config.yaml" 2>/dev/null

echo "Done!"
