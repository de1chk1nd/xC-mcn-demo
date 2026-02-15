#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer: lb-bigip-echo-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' \
    -d @"${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/etc/lb-bigip-echo-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-bigip-echo-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' \
    -d @"${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/etc/lb-bigip-echo-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
