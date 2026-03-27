#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "bigip-echo-eu-central.${STUDENT}.xc-mcn-lab.aws"
    "bigip-echo-eu-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-bigip-echo-eu-central"
    "tls-${STUDENT}-bigip-echo-eu-west"
)

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-bigip-echo-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-bigip-echo-eu-central"

echo "Deleting load balancer: lb-bigip-echo-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-bigip-echo-eu-west"

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
