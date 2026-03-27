#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/North-South Loadbalancer - RE to CE"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "echo-hybrid.${STUDENT}.xc-mcn-lab.aws"
    "echo-hybrid-central.${STUDENT}.xc-mcn-lab.aws"
    "echo-hybrid-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-echo-hybrid"
    "tls-${STUDENT}-echo-hybrid-central"
    "tls-${STUDENT}-echo-hybrid-west"
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

    sleep 3
done

#######################################
# Generate Payloads from Templates
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template_lb-echo-ssl.json" > "${USE_CASE_DIR}/payload_final_lb-echo-ssl.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-echo-ssl-central.json" > "${USE_CASE_DIR}/payload_final_lb-echo-ssl-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-echo-ssl-west.json" > "${USE_CASE_DIR}/payload_final_lb-echo-ssl-west.json"

#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer: lb-echo-hybrid..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-echo-ssl.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-echo-hybrid-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-echo-ssl-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-echo-hybrid-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-echo-ssl-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
