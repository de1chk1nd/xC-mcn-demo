#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/RE-to-CE-bigip"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "bigip-echo-eu-central.${STUDENT}.xc-mcn-lab.aws"
    "bigip-echo-eu-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-bigip-echo-eu-central"
    "tls-${STUDENT}-bigip-echo-eu-west"
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
envsubst < "${USE_CASE_DIR}/etc/__template_lb-bigip-echo-eu-central.json" > "${USE_CASE_DIR}/payload_final_lb-bigip-echo-eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-bigip-echo-eu-west.json" > "${USE_CASE_DIR}/payload_final_lb-bigip-echo-eu-west.json"

#######################################
# Create Load Balancers
#######################################
echo "Creating load balancer: lb-bigip-echo-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-bigip-echo-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-bigip-echo-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-bigip-echo-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
