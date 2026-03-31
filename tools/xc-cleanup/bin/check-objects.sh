#!/usr/bin/env bash
set -euo pipefail

# xC MCN Demo Lab — xC Object Cleanup Checker
# Checks whether all xC objects created by use-case scripts still exist.
# Read-only: performs GET requests only, does not delete anything.

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")

# ANSI colors
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

FOUND=0
CLEAN=0
ERRORS=0

BASE_URL="https://${TENANT}.console.ves.volterra.io/api/config/namespaces/${NAMESPACE}"

# ─────────────────────────────────────────────────────
# Helper: check a single object
# check_object <type> <name> <use_case>
# ─────────────────────────────────────────────────────
check_object() {
    local type="$1"
    local name="$2"
    local use_case="$3"
    local url="${BASE_URL}/${type}/${name}"

    local http_code
    http_code=$(curl --silent --cert "${CERT_FILE}:${P12_PASSWORD}" \
        -o /dev/null -w "%{http_code}" \
        "${url}" 2>/dev/null) || { ERRORS=$((ERRORS + 1)); return; }

    if [ "${http_code}" = "200" ]; then
        printf "  ${RED}✗ EXISTS${RESET}  %-30s  %-18s  %s\n" "${name}" "${type}" "${use_case}"
        FOUND=$((FOUND + 1))
    elif [ "${http_code}" = "404" ]; then
        printf "  ${GREEN}✓ clean${RESET}   %-30s  %-18s  %s\n" "${name}" "${type}" "${use_case}"
        CLEAN=$((CLEAN + 1))
    else
        printf "  ${YELLOW}? ${http_code}${RESET}     %-30s  %-18s  %s\n" "${name}" "${type}" "${use_case}"
        ERRORS=$((ERRORS + 1))
    fi
}

# ─────────────────────────────────────────────────────
clear
printf "${BOLD}══════════════════════════════════════════════════════════════════${RESET}\n"
printf "${BOLD}  xC MCN Demo Lab — Object Cleanup Check${RESET}\n"
printf "${BOLD}  Tenant:    ${RESET}${TENANT}\n"
printf "${BOLD}  Namespace: ${RESET}${NAMESPACE}\n"
printf "${BOLD}  Student:   ${RESET}${STUDENT}\n"
printf "${BOLD}══════════════════════════════════════════════════════════════════${RESET}\n"
printf "\n"
printf "  ${BOLD}%-32s  %-18s  %s${RESET}\n" "Object Name" "Type" "Use Case"
printf "  %s\n" "──────────────────────────────────────────────────────────────"

# ─────────────────────────────────────────────────────
# HTTP Load Balancers
# ─────────────────────────────────────────────────────
check_object "http_loadbalancers" "lb-echo-public"                   "RE-only"
check_object "http_loadbalancers" "lb-echo-hybrid"                   "RE-to-CE"
check_object "http_loadbalancers" "lb-echo-hybrid-central"           "RE-to-CE"
check_object "http_loadbalancers" "lb-echo-hybrid-west"              "RE-to-CE"
check_object "http_loadbalancers" "lb-bigip-echo-eu-central"         "RE-to-CE-bigip"
check_object "http_loadbalancers" "lb-bigip-echo-eu-west"            "RE-to-CE-bigip"
check_object "http_loadbalancers" "lb-ce-central"                    "CE-via-CLB"
check_object "http_loadbalancers" "lb-ce-west"                       "CE-via-CLB"
check_object "http_loadbalancers" "lb-api-int-central"               "CE-to-CE"
check_object "http_loadbalancers" "lb-api-int-west"                  "CE-to-CE"
check_object "http_loadbalancers" "lb-k8s"                           "k8s-SD"
check_object "http_loadbalancers" "lb-k8s-central"                   "k8s-SD"
check_object "http_loadbalancers" "lb-k8s-west"                      "k8s-SD"
check_object "http_loadbalancers" "lb-vk8s-eu-central"               "vk8s"
check_object "http_loadbalancers" "lb-vk8s-eu-west"                  "vk8s"
check_object "http_loadbalancers" "lb-${STUDENT}-mtls"               "svc-mtls"
check_object "http_loadbalancers" "lb-${STUDENT}-jwt"                "svc-jwt"

# ─────────────────────────────────────────────────────
# Origin Pools
# ─────────────────────────────────────────────────────
check_object "origin_pools" "origin-public-echo-aws"                 "RE-only"
check_object "origin_pools" "origin-k8s-central"                     "k8s-SD"
check_object "origin_pools" "origin-k8s-west"                        "k8s-SD"
check_object "origin_pools" "origin-vk8s-eu-central"                 "vk8s"
check_object "origin_pools" "origin-vk8s-eu-west"                    "vk8s"

# ─────────────────────────────────────────────────────
# Certificates
# ─────────────────────────────────────────────────────
check_object "certificates" "tls-${STUDENT}-echo-public"             "RE-only"
check_object "certificates" "tls-${STUDENT}-echo-hybrid"             "RE-to-CE"
check_object "certificates" "tls-${STUDENT}-echo-hybrid-central"     "RE-to-CE"
check_object "certificates" "tls-${STUDENT}-echo-hybrid-west"        "RE-to-CE"
check_object "certificates" "tls-${STUDENT}-bigip-echo-eu-central"   "RE-to-CE-bigip"
check_object "certificates" "tls-${STUDENT}-bigip-echo-eu-west"      "RE-to-CE-bigip"
check_object "certificates" "tls-${STUDENT}-app-ce-eu-central-1"     "CE-via-CLB"
check_object "certificates" "tls-${STUDENT}-app-ce-eu-west-1"        "CE-via-CLB"
check_object "certificates" "tls-${STUDENT}-remote-web"              "CE-to-CE"
check_object "certificates" "tls-${STUDENT}-k8s"                     "k8s-SD"
check_object "certificates" "tls-${STUDENT}-k8s-central"             "k8s-SD"
check_object "certificates" "tls-${STUDENT}-k8s-west"                "k8s-SD"
check_object "certificates" "tls-${STUDENT}-vk8s-eu-central"         "vk8s"
check_object "certificates" "tls-${STUDENT}-vk8s-eu-west"            "vk8s"
check_object "certificates" "tls-${STUDENT}-mtls"                    "svc-mtls"
check_object "certificates" "tls-${STUDENT}-jwt"                     "svc-jwt"

# ─────────────────────────────────────────────────────
# Service Discoveries
# ─────────────────────────────────────────────────────
check_object "discoverys" "sd-k8s-${STUDENT}-eu-central"             "k8s-SD"
check_object "discoverys" "sd-k8s-${STUDENT}-eu-west"                "k8s-SD"

# ─────────────────────────────────────────────────────
# Virtual K8s + Workloads
# ─────────────────────────────────────────────────────
check_object "virtual_k8ss" "${STUDENT}-vk8s"                        "vk8s"
check_object "workloads"    "echo-aws"                                "vk8s"

# ─────────────────────────────────────────────────────
# mTLS specific
# ─────────────────────────────────────────────────────
check_object "trusted_ca_lists" "ca-${STUDENT}-mtls"                 "svc-mtls"
check_object "service_policys"  "sp-${STUDENT}-mtls-cert-check"      "svc-mtls"

# ─────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────
printf "\n"
printf "  %s\n" "──────────────────────────────────────────────────────────────"
printf "  ${RED}✗ Exists:${RESET}  ${FOUND}  ${GREEN}✓ Clean:${RESET}  ${CLEAN}  ${YELLOW}? Errors:${RESET}  ${ERRORS}\n"
printf "\n"

if [ "${FOUND}" -gt 0 ]; then
    printf "  ${YELLOW}Objects still present — run the corresponding delete script:${RESET}\n"
    printf "  ${YELLOW}  make uc-<name>-delete  or  make svc-<name>-delete${RESET}\n"
    printf "\n"
    exit 1
else
    printf "  ${GREEN}All lab objects are clean.${RESET}\n"
    printf "\n"
    exit 0
fi
