#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "echo-hybrid.${STUDENT}.xc-mcn-lab.aws"
    "echo-hybrid-central.${STUDENT}.xc-mcn-lab.aws"
    "echo-hybrid-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-echo-hybrid"
    "tls-${STUDENT}-echo-hybrid-central"
    "tls-${STUDENT}-echo-hybrid-west"
)

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-echo-hybrid..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-echo-hybrid"

echo "Deleting load balancer: lb-echo-hybrid-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-echo-hybrid-central"

echo "Deleting load balancer: lb-echo-hybrid-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-echo-hybrid-west"

#######################################
# Delete Certificates
#######################################
for i in "${!TLS_NAMES[@]}"; do
    echo "Deleting certificate: ${TLS_NAMES[$i]}..."
    curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
        -I -X DELETE \
        "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/certificates/${TLS_NAMES[$i]}"
done

#######################################
# Cleanup generated files
#######################################
rm -f "${USE_CASE_DIR}"/payload_final_*.json
for DOMAIN in "${DOMAINS[@]}"; do
    rm -f "${CERT_DIR}/${DOMAIN}.cert" "${CERT_DIR}/${DOMAIN}.key" 2>/dev/null
done
rm -f "${REPO_ROOT}/tools/s-certificate/config/config.yaml" 2>/dev/null

echo "Done!"
