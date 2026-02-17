#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/vk8s"

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

#######################################
# Step 4: Destroy vk8s via Terraform
#######################################
echo "Running Terraform to destroy vk8s..."
export VES_P12_PASSWORD="${P12_PASSWORD}"
terraform -chdir="${USE_CASE_DIR}/terraform" destroy -auto-approve

#######################################
# Cleanup generated files
#######################################
rm -f "${USE_CASE_DIR}/payload_final_eu-central.json"
rm -f "${USE_CASE_DIR}/payload_final_eu-west.json"

echo "Done!"
