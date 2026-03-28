#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/RE-only"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
DOMAIN="echo-public.${STUDENT}.xc-mcn-lab.aws"
TLS_CERT_NAME="tls-${STUDENT}-echo-public"
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"

#######################################
# Get Terraform Outputs
#######################################
export UBUNTU_NLB_EU_CENTRAL=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-central-1 | tr -d '\"')
export UBUNTU_NLB_EU_WEST=$(terraform -chdir="${REPO_ROOT}/infrastructure" output ubuntu-01-nlb-private-eu-west-1 | tr -d '\"')

#######################################
# Generate Server Certificate
#######################################
# Ensure s-certificate tool config exists (copy from example if missing)
S_CERT_CONFIG="${REPO_ROOT}/tools/s-certificate/config/config.yaml"
if [ ! -f "${S_CERT_CONFIG}" ]; then
    cp "${S_CERT_CONFIG}.example" "${S_CERT_CONFIG}"
    echo "Created s-certificate config from example."
fi

echo "Generating server certificate for: ${DOMAIN}..."
"${REPO_ROOT}/tools/s-certificate/bin/run-s-certificate.sh" "${DOMAIN}" --no-p12 --keep-pem

#######################################
# Upload Certificate to xC
#######################################
echo "Uploading certificate to xC: ${TLS_CERT_NAME}..."

CERT_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.cert" | tr -d '\n')
KEY_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.key" | tr -d '\n')

CERT_PAYLOAD=$(cat <<EOF
{
  "metadata": {
    "name": "${TLS_CERT_NAME}",
    "namespace": "${NAMESPACE}",
    "description": "Server certificate for ${DOMAIN}",
    "disable": false
  },
  "spec": {
    "certificate_url": "string:///${CERT_PEM_B64}",
    "private_key": {
      "clear_secret_info": {
        "url": "string:///${KEY_PEM_B64}",
        "provider": ""
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

sleep 5

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
