#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/vk8s"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

#######################################
# Step 1: Create vk8s via Terraform
#######################################
echo "Running Terraform to create vk8s..."
export VES_P12_PASSWORD="${P12_PASSWORD}"

terraform -chdir="${USE_CASE_DIR}/terraform" fmt
terraform -chdir="${USE_CASE_DIR}/terraform" init
terraform -chdir="${USE_CASE_DIR}/terraform" plan
terraform -chdir="${USE_CASE_DIR}/terraform" apply -auto-approve

echo "vk8s created."

#######################################
# Step 2: Get Terraform Outputs
#######################################
export MCN_CE_EU_CENTRAL1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')
export MCN_CE_EU_CENTRAL1_GW01=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-CENTRAL1-GW01 | tr -d '\"')
export MCN_CE_EU_WEST1_GW01=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-WEST1-GW01 | tr -d '\"')

#######################################
# Step 3: Generate All Payloads
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template_workload.json" > "${USE_CASE_DIR}/payload_final_workload.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin-vk8s-eu-central.json" > "${USE_CASE_DIR}/payload_final_eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin-vk8s-eu-west.json" > "${USE_CASE_DIR}/payload_final_eu-west.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-vk8s-eu-central.json" > "${USE_CASE_DIR}/payload_final_lb-eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-vk8s-eu-west.json" > "${USE_CASE_DIR}/payload_final_lb-eu-west.json"

#######################################
# Step 4: Create Workload
#######################################
echo "Creating workload: echo-aws..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_workload.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/workloads"

echo "Waiting for workload to initialize..."
sleep 10

#######################################
# Step 5: Create Origin Pools
#######################################
echo "Creating origin pool: origin-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

echo "Creating origin pool: origin-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

sleep 5

#######################################
# Step 6: Create Load Balancers
#######################################
echo "Creating load balancer: lb-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
