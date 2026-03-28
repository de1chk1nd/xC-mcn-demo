#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/k8s-service-discovery"

# Certificate settings
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "k8s.${STUDENT}.xc-mcn-lab.aws"
    "k8s-central.${STUDENT}.xc-mcn-lab.aws"
    "k8s-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-k8s"
    "tls-${STUDENT}-k8s-central"
    "tls-${STUDENT}-k8s-west"
)

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-k8s..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s"

echo "Deleting load balancer: lb-k8s-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s-central"

echo "Deleting load balancer: lb-k8s-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s-west"

#######################################
# Delete Origin Pools
#######################################
echo "Deleting origin pool: origin-k8s-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools/origin-k8s-central"

echo "Deleting origin pool: origin-k8s-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools/origin-k8s-west"

#######################################
# Delete Service Discovery
#######################################
echo "Deleting service discovery: sd-k8s-${STUDENT}-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/discoverys/sd-k8s-${STUDENT}-eu-central"

echo "Deleting service discovery: sd-k8s-${STUDENT}-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/discoverys/sd-k8s-${STUDENT}-eu-west"

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
rm -f "${USE_CASE_DIR}/etc/kubeconfig-eu-central"
rm -f "${USE_CASE_DIR}/etc/kubeconfig-eu-west"
for DOMAIN in "${DOMAINS[@]}"; do
    rm -f "${CERT_DIR}/${DOMAIN}.cert" "${CERT_DIR}/${DOMAIN}.key" 2>/dev/null
done
rm -f "${REPO_ROOT}/tools/s-certificate/config/config.yaml" 2>/dev/null

echo "Done!"
