#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Service Discovery/kubernetes"

#######################################
# Delete Load Balancers
#######################################
echo "Deleting load balancer: lb-k8s-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s-central"

echo "Deleting load balancer: lb-k8s-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s-west"

echo "Deleting load balancer: lb-k8s..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers/lb-k8s"

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
# Delete Service Discovery (system namespace)
#######################################
echo "Deleting service discovery: sd-k8s-de1chk1nd-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-central"

echo "Deleting service discovery: sd-k8s-de1chk1nd-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -I -X DELETE \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-west"

#######################################
# Cleanup generated files
#######################################
rm -f "${USE_CASE_DIR}/payload_final_eu-central.json"
rm -f "${USE_CASE_DIR}/payload_final_eu-west.json"
rm -f "${USE_CASE_DIR}/payload_final_origin_eu-central.json"
rm -f "${USE_CASE_DIR}/payload_final_origin_eu-west.json"
rm -f "${USE_CASE_DIR}/etc/kubeconfig-eu-central"
rm -f "${USE_CASE_DIR}/etc/kubeconfig-eu-west"

echo "Done!"
