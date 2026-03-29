#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Services/tls-authentication"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
CA_CERT="${REPO_ROOT}/setup-init/.cert/ca/ca.cer"
CA_KEY="${REPO_ROOT}/setup-init/.cert/ca/ca.key"
DOMAIN="mtls.${STUDENT}.xc-mcn-lab.aws"
TLS_CERT_NAME="tls-${STUDENT}-mtls"

# Client users
CLIENT_USERS=("alice@mordor.de" "bob@shire.de")

#######################################
# Ensure s-certificate tool config
#######################################
S_CERT_CONFIG="${REPO_ROOT}/tools/s-certificate/config/config.yaml"
if [ ! -f "${S_CERT_CONFIG}" ]; then
    cp "${S_CERT_CONFIG}.example" "${S_CERT_CONFIG}"
    echo "Created s-certificate config from example."
fi

#######################################
# Step 1: Generate & Upload Server Certificate
#######################################
echo "Generating server certificate for: ${DOMAIN}..."
"${REPO_ROOT}/tools/s-certificate/bin/run-s-certificate.sh" "${DOMAIN}" --no-p12 --keep-pem

echo "Uploading server certificate to xC: ${TLS_CERT_NAME}..."
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

sleep 3

#######################################
# Step 2: Generate Client Certificates
#######################################
echo "Generating client certificates..."
CLIENT_CERT_DIR="${USE_CASE_DIR}/etc/client-certs"
mkdir -p "${CLIENT_CERT_DIR}"

# CA serial file (reuse from setup-init)
CA_SERIAL="${REPO_ROOT}/setup-init/.cert/ca/ca.srl"
SERIAL_ARGS="-CAserial ${CA_SERIAL}"
if [ ! -f "${CA_SERIAL}" ]; then
    SERIAL_ARGS="${SERIAL_ARGS} -CAcreateserial"
fi

for EMAIL in "${CLIENT_USERS[@]}"; do
    # Derive a safe filename from email (replace @ and . with -)
    SAFE_NAME=$(echo "${EMAIL}" | tr '@.' '--')

    echo "  Generating client cert for: ${EMAIL} (${SAFE_NAME})..."

    # Generate private key
    openssl genrsa -out "${CLIENT_CERT_DIR}/${SAFE_NAME}.key" 2048 2>/dev/null

    # Create CSR with email as CN and emailAddress
    openssl req -new \
        -key "${CLIENT_CERT_DIR}/${SAFE_NAME}.key" \
        -out "${CLIENT_CERT_DIR}/${SAFE_NAME}.csr" \
        -subj "/C=DE/ST=Lab/L=Lab/O=xC-MCN-Lab/OU=${STUDENT}/CN=${EMAIL}/emailAddress=${EMAIL}" \
        2>/dev/null

    # Write extensions config for clientAuth
    cat > "${CLIENT_CERT_DIR}/${SAFE_NAME}.ext" <<EXTEOF
[v3_req]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = email:${EMAIL}
EXTEOF

    # Sign with CA
    openssl x509 -req -days 365 \
        -in "${CLIENT_CERT_DIR}/${SAFE_NAME}.csr" \
        -CA "${CA_CERT}" \
        -CAkey "${CA_KEY}" \
        ${SERIAL_ARGS} \
        -out "${CLIENT_CERT_DIR}/${SAFE_NAME}.cert" \
        -extensions v3_req \
        -extfile "${CLIENT_CERT_DIR}/${SAFE_NAME}.ext" \
        2>/dev/null

    # Cleanup intermediate files
    rm -f "${CLIENT_CERT_DIR}/${SAFE_NAME}.csr" "${CLIENT_CERT_DIR}/${SAFE_NAME}.ext"

    echo "    Created: ${CLIENT_CERT_DIR}/${SAFE_NAME}.cert"
    echo "    Key:     ${CLIENT_CERT_DIR}/${SAFE_NAME}.key"

    # After first cert, serial file exists
    SERIAL_ARGS="-CAserial ${CA_SERIAL}"
done

#######################################
# Step 3: Generate Payloads from Templates
#######################################
echo "Generating payloads from templates..."

# Base64-encode the CA cert for the trusted_ca_url
export CA_CERT_B64=$(base64 < "${CA_CERT}" | tr -d '\n')

envsubst < "${USE_CASE_DIR}/etc/__template_trusted-ca.json" > "${USE_CASE_DIR}/payload_final_trusted-ca.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-mtls.json" > "${USE_CASE_DIR}/payload_final_lb-mtls.json"
envsubst < "${USE_CASE_DIR}/etc/__template_service-policy.json" > "${USE_CASE_DIR}/payload_final_service-policy.json"

#######################################
# Step 4: Create Trusted CA List
#######################################
echo "Creating trusted CA list: ca-${STUDENT}-mtls..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_trusted-ca.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/trusted_ca_lists"

sleep 3

#######################################
# Step 5: Create Load Balancer
#######################################
echo "Creating load balancer: lb-${STUDENT}-mtls..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-mtls.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

sleep 3

#######################################
# Step 6: Create Service Policy
#######################################
echo "Creating service policy: sp-${STUDENT}-mtls-cert-check..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_service-policy.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/service_policys"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Server FQDN: https://${DOMAIN}"
echo "Client certs: ${CLIENT_CERT_DIR}/"
echo ""
echo "Test with curl:"
for EMAIL in "${CLIENT_USERS[@]}"; do
    SAFE_NAME=$(echo "${EMAIL}" | tr '@.' '--')
    echo ""
    echo "  # ${EMAIL}"
    echo "  curl -k --cert ${CLIENT_CERT_DIR}/${SAFE_NAME}.cert --key ${CLIENT_CERT_DIR}/${SAFE_NAME}.key https://${DOMAIN}"
done
echo ""
echo "Done!"
