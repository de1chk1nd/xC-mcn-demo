#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

USE_CASE_DIR="${REPO_ROOT}/xC-use-cases/Architecture/vk8s"

# Load additional config values for envsubst
export STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# Certificate settings
CERT_DIR="${REPO_ROOT}/setup-init/.cert/domains"
DOMAINS=(
    "vk8s-eu-central.${STUDENT}.xc-mcn-lab.aws"
    "vk8s-eu-west.${STUDENT}.xc-mcn-lab.aws"
)
TLS_NAMES=(
    "tls-${STUDENT}-vk8s-eu-central"
    "tls-${STUDENT}-vk8s-eu-west"
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
# Step 1: Get Terraform Outputs
#######################################
export MCN_CE_EU_CENTRAL1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')
export MCN_CE_EU_CENTRAL1_GW01=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-CENTRAL1-GW01 | tr -d '\"')
export MCN_CE_EU_WEST1_GW01=$(terraform -chdir="${REPO_ROOT}/infrastructure" output xC-MCN-CE-EU-WEST1-GW01 | tr -d '\"')

#######################################
# Step 2: Generate & Upload Certificates
#######################################
for i in "${!DOMAINS[@]}"; do
    DOMAIN="${DOMAINS[$i]}"
    TLS_NAME="${TLS_NAMES[$i]}"

    echo "Generating server certificate for: ${DOMAIN}..."
    "${REPO_ROOT}/tools/s-certificate/bin/run-s-certificate.sh" "${DOMAIN}" --no-p12 --keep-pem

    echo "Uploading certificate to xC: ${TLS_NAME}..."
    CERT_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.cert" | tr -d '\n')
    KEY_PEM_B64=$(base64 < "${CERT_DIR}/${DOMAIN}.key" | tr -d '\n')

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
# Step 3: Generate All Payloads
#######################################
echo "Generating payload files from templates..."
envsubst < "${USE_CASE_DIR}/etc/__template_vk8s-cluster.json" > "${USE_CASE_DIR}/payload_final_vk8s-cluster.json"
envsubst < "${USE_CASE_DIR}/etc/__template_workload.json" > "${USE_CASE_DIR}/payload_final_workload.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin-vk8s-eu-central.json" > "${USE_CASE_DIR}/payload_final_eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_origin-vk8s-eu-west.json" > "${USE_CASE_DIR}/payload_final_eu-west.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-vk8s-eu-central.json" > "${USE_CASE_DIR}/payload_final_lb-eu-central.json"
envsubst < "${USE_CASE_DIR}/etc/__template_lb-vk8s-eu-west.json" > "${USE_CASE_DIR}/payload_final_lb-eu-west.json"

#######################################
# Step 4: Create vk8s Cluster
#######################################
echo "Creating vk8s cluster: ${STUDENT}-vk8s..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_vk8s-cluster.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/virtual_k8ss"

echo "Waiting for vk8s cluster to initialize..."
sleep 15

#######################################
# Step 5: Create Workload
#######################################
echo "Creating workload: echo-aws..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_workload.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/workloads"

echo "Waiting for workload to initialize..."
sleep 10

#######################################
# Step 6: Create Origin Pools
#######################################
echo "Creating origin pool: origin-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

echo "Creating origin pool: origin-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/origin_pools"

sleep 5

#######################################
# Step 7: Create Load Balancers
#######################################
echo "Creating load balancer: lb-vk8s-eu-central..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-eu-central.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Creating load balancer: lb-vk8s-eu-west..."
curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
    -i -X POST -H 'Content-Type: application/json' -s -D - -o /dev/null \
    -d @"${USE_CASE_DIR}/payload_final_lb-eu-west.json" \
    "https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}/http_loadbalancers"

echo "Done!"
