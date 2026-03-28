#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/CE-to-CE"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAIN="remote-web.${STUDENT}.xc-mcn-lab.aws"
TLS_CERT_NAME="tls-${STUDENT}-remote-web"

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
