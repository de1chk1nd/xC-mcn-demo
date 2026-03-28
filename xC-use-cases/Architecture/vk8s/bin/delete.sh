#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/vk8s"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "vk8s-eu-central.${STUDENT}.xc-mcn-lab.aws"
    "vk8s-eu-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-vk8s-eu-central"
    "tls-${STUDENT}-vk8s-eu-west"
)

#######################################
# Step 1: Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-vk8s-eu-central"

echo "Deleting load balancer: lb-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-vk8s-eu-west"

#######################################
# Step 2: Delete Origin Pools
#######################################
echo "Deleting origin pool: origin-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools/origin-vk8s-eu-central"

echo "Deleting origin pool: origin-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools/origin-vk8s-eu-west"

#######################################
# Step 3: Delete Workload
#######################################
echo "Deleting workload: echo-aws..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/workloads/echo-aws"

sleep 5

#######################################
# Step 4: Delete vk8s Cluster
#######################################
echo "Deleting vk8s cluster: ${STUDENT}-vk8s..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/virtual_k8ss/${STUDENT}-Architecture/vk8s"

#######################################
# Step 5: Delete Certificates
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
