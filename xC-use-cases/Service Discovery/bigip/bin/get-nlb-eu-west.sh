#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

# Load student name from config
STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
SSH_KEY="${REPO_ROOT}/setup-init/.ssh/${STUDENT}-ssh.pem"

#######################################
# Get NLB IP
#######################################
export NLB_DNS_EU_WEST1=$(terraform -chdir="${REPO_ROOT}/infrastructure" output BigIP-MGMTip-nlb-private-eu-west-1 | tr -d '\"')
/usr/bin/ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" \
    ubuntu@ubuntu-eu-west-1.${STUDENT}-lab.aws \
    "HOST_TO_LOOKUP='$NLB_DNS_EU_WEST1'; sudo nslookup \$HOST_TO_LOOKUP" | grep "Address:" | grep -v "#53"
