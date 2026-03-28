#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/CE-via-CLB"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "app-ce-eu-central-1.${STUDENT}.xc-mcn-lab.aws"
    "app-ce-eu-west-1.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-app-ce-eu-central-1"
    "tls-${STUDENT}-app-ce-eu-west-1"
)

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-ce-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-ce-central"

echo "Deleting load balancer: lb-ce-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-ce-west"

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
