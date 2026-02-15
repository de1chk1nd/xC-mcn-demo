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
echo "Creating load balancer: lb-echo-ssl..."
curl --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-echo-ssl.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"
echo "Creating load balancer: lb-echo-ssl-central..."
curl --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-echo-ssl-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"
echo "Creating load balancer: lb-echo-ssl-west..."
curl --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-echo-ssl-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"
echo "Done!"