#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Services/jwt-validation"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
CA_KEY="${REPO_ROOT}/setup-init/.cert/ca/ca.key"
DOMAIN="jwt.${STUDENT}.xc-mcn-lab.aws"
TLS_CERT_NAME="tls-${STUDENT}-jwt"
TOKEN_DIR="${USE_CASE_DIR}/etc/tokens"

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
# Step 2: Generate JWT Tokens + JWKS
#######################################
echo "Generating JWT tokens and JWKS..."

# Ensure PyJWT + cryptography are available
pip install -q PyJWT cryptography 2>/dev/null || true

python3 "${USE_CASE_DIR}/bin/generate-tokens.py" \
    "${CA_KEY}" \
    "${STUDENT}" \
    "${TOKEN_DIR}"

#######################################
# Step 3: Generate LB Payload
#######################################
echo "Generating payload from template..."

# Base64-encode the JWKS for the cleartext field (string:/// prefix is in template)
export JWKS_B64=$(base64 < "${TOKEN_DIR}/jwks.json" | tr -d '\n')

envsubst < "${USE_CASE_DIR}/etc/__template_lb-jwt.json" > "${USE_CASE_DIR}/payload_final_lb-jwt.json"

#######################################
# Step 4: Create Load Balancer
#######################################
echo "Creating load balancer: lb-jwt..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-jwt.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Server FQDN: https://${DOMAIN}"
echo ""
echo "Test with curl:"
echo ""
echo "  # Test 1: No token (should be blocked)"
echo "  curl -vk https://${DOMAIN}"
echo ""
echo "  # Test 2: Valid token (should pass)"
echo "  curl -vk -H \"Authorization: Bearer \$(cat ${TOKEN_DIR}/valid.jwt)\" https://${DOMAIN}"
echo ""
echo "  # Test 3: Invalid claim (should be blocked)"
echo "  curl -vk -H \"Authorization: Bearer \$(cat ${TOKEN_DIR}/invalid.jwt)\" https://${DOMAIN}"
echo ""
echo "Done!"
