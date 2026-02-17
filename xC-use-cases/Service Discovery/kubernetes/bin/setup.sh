#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Service Discovery/kubernetes"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
SSH_KEY="${REPO_ROOT}/setup-init/.ssh/${STUDENT}-ssh.pem"

#######################################
# Get Remote Kubeconfig Files
#######################################
echo "Fetching kubeconfig from eu-central-1..."
/usr/bin/ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-central-1.${STUDENT}-lab.aws \
    'sudo kubectl config view --flatten' > "${USE_CASE_DIR}/etc/kubeconfig-eu-central"
/usr/bin/ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-central-1.${STUDENT}-lab.aws \
    'sudo kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml'

echo "Fetching kubeconfig from eu-west-1..."
/usr/bin/ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-west-1.${STUDENT}-lab.aws \
    'sudo kubectl config view --flatten' > "${USE_CASE_DIR}/etc/kubeconfig-eu-west"
/usr/bin/ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-west-1.${STUDENT}-lab.aws \
    'sudo kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml'

#######################################
# Create Environment Variables
#######################################
export KUBECONFIG_EU_CENTRAL1=$(base64 "${USE_CASE_DIR}/etc/kubeconfig-eu-central" | tr -d '\n')
export KUBECONFIG_EU_WEST1=$(base64 "${USE_CASE_DIR}/etc/kubeconfig-eu-west" | tr -d '\n')

#######################################
# Generate Payloads from Templates
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template_sd_eu-central.json" > "${USE_CASE_DIR}/payload_final_sd-eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_sd_eu-west.json" > "${USE_CASE_DIR}/payload_final_sd-eu-west.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin_eu-central.json" > "${USE_CASE_DIR}/payload_final_origin-eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin_eu-west.json" > "${USE_CASE_DIR}/payload_final_origin-eu-west.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-k8s.json" > "${USE_CASE_DIR}/payload_final_lb-k8s.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-k8s-central.json" > "${USE_CASE_DIR}/payload_final_lb-k8s-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-k8s-west.json" > "${USE_CASE_DIR}/payload_final_lb-k8s-west.json"

#######################################
# Create Service Discovery
#######################################
echo "Creating service discovery: sd-k8s-${STUDENT}-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_sd-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/discoverys"

echo "Creating service discovery: sd-k8s-${STUDENT}-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_sd-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/discoverys"

sleep 5

#######################################
# Create Origin Pools
#######################################
echo "Creating origin pool: origin-k8s-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_origin-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

echo "Creating origin pool: origin-k8s-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_origin-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

sleep 5

#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer: lb-k8s-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-k8s-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-k8s-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-k8s-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-k8s..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-k8s.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
