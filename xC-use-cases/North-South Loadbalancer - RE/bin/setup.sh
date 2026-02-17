#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

#######################################
# Get Terraform Outputs
#######################################
export UBUNTU_NLB_EU_CENTRAL=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-central-1 | tr -d '\"')
export UBUNTU_NLB_EU_WEST=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-west-1 | tr -d '\"')

#######################################
# Generate Payloads from Templates
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template__origin-pool.json" > "${USE_CASE_DIR}/payload_final_origin-pool.json"
envsubst < "${USE_CASE_DIR}/etc/__template_http-loadbalancer.json" > "${USE_CASE_DIR}/payload_final_http-loadbalancer.json"

#######################################
# Create Origin Pool
#######################################
echo "Creating origin pool: origin-public-echo-aws..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_origin-pool.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

sleep 5

#######################################
# Create Load Balancer
#######################################
echo "Creating load balancer: lb-echo-public..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_http-loadbalancer.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
