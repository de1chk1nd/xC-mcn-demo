#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/k8s-service-discovery"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
SSH_KEY="${REPO_ROOT}/setup-init/.ssh/${STUDENT}-ssh.pem"

# Certificate settings
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
# Ensure s-certificate tool config
#######################################
S_CERT_CONFIG="${REPO_ROOT}/tools/s-certificate/config/config.yaml"
if [ ! -f "${S_CERT_CONFIG}" ]; then
    cp "${S_CERT_CONFIG}.example" "${S_CERT_CONFIG}"
    echo "Created s-certificate config from example."
fi

#######################################
# Get Remote Kubeconfig Files
#######################################
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

echo "Fetching kubeconfig from eu-central-1..."
/usr/bin/ssh ${SSH_OPTS} -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-central-1.${STUDENT}.xc-mcn-lab.aws \
    'sudo kubectl config view --flatten' > "${USE_CASE_DIR}/etc/kubeconfig-eu-central"
/usr/bin/ssh ${SSH_OPTS} -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-central-1.${STUDENT}.xc-mcn-lab.aws \
    'sudo kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml'

echo "Fetching kubeconfig from eu-west-1..."
/usr/bin/ssh ${SSH_OPTS} -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-west-1.${STUDENT}.xc-mcn-lab.aws \
    'sudo kubectl config view --flatten' > "${USE_CASE_DIR}/etc/kubeconfig-eu-west"
/usr/bin/ssh ${SSH_OPTS} -i "${SSH_KEY}" \
    ubuntu@ubuntu-01-eu-west-1.${STUDENT}.xc-mcn-lab.aws \
    'sudo kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml'

#######################################
# Create Environment Variables
#######################################
export KUBECONFIG_EU_CENTRAL1=$(base64 < "${USE_CASE_DIR}/etc/kubeconfig-eu-central" | tr -d '\n')
export KUBECONFIG_EU_WEST1=$(base64 < "${USE_CASE_DIR}/etc/kubeconfig-eu-west" | tr -d '\n')

#######################################
# Generate & Upload Certificates
#######################################
for i in "${!DOMAINS[@]}"; do
    DOMAIN="${DOMAINS[$i]}"
    TLS_NAME="${TLS_NAMES[$i]}"

    echo "Generating server certificate for: ${DOMAIN}..."
    "${REPO_ROOT}/tools/s-certificate/bin/run-s-certificate.sh" "${DOMAIN}" --no-p12 --keep-pem

    echo "Uploading certificate to xC: ${TLS_NAME}..."
    CERT_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.cert")
    KEY_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.key")

    CERT_PAYLOAD=$(cat <<EOF
{
  "metadata": {
    "name": "${TLS_NAME}",
    "namespace": "${NAMESPACE}",
    "description": "Server certificate for ${DOMAIN}",
    "disable": false
  },
  "spec": {
    "certificate_url": "string:///${CERT_PEM_B64}",
    "private_key": {
      "clear_secret_info": {
        "url": "string:///${KEY_PEM_B64}",
        "provider": "
      }
    }
  }
}
EOF
)

    curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
        -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
        -d "${CERT_PAYLOAD}" \
        "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/certificates"

    sleep 3
done

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
