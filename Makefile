# xC MCN Demo Lab — Makefile
# Run 'make' or 'make help' to see all available targets.

REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null)
SETUP_INIT := $(REPO_ROOT)/setup-init
INFRA      := $(REPO_ROOT)/infrastructure

# OS-specific SSH script
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
  SSH_SCRIPT := $(SETUP_INIT)/.ssh/ssh-key-permission_mac.sh
else
  SSH_SCRIPT := $(SETUP_INIT)/.ssh/ssh-key-permission_lnx.sh
endif

# Default target
.DEFAULT_GOAL := help

# ─────────────────────────────────────────────────────
.PHONY: help
help:
	@echo ""
	@echo "  xC MCN Demo Lab — Makefile Targets"
	@echo "  ══════════════════════════════════════════════"
	@echo ""
	@echo "  BASICS"
	@echo "    install            Full lab initialization (Terraform + xC)"
	@echo "    delete             Destroy all infrastructure"
	@echo "    update-creds       Update AWS credentials (after STS rotation)"
	@echo "    update-ip          Update public IP + refresh Security Groups [BETA]"
	@echo "    generate-ca        Generate Certificate Authority only"
	@echo ""
	@echo "  SSH"
	@echo "    ssh                Open SSH to all lab servers (auto-detects OS)"
	@echo "    ssh-central        SSH to eu-central servers only"
	@echo "    ssh-west           SSH to eu-west servers only"
	@echo "    ssh-ubuntu         SSH to all Ubuntu servers"
	@echo "    ssh-bigip          SSH to all BIG-IP servers"
	@echo ""
	@echo "  USE CASES — ARCHITECTURE"
	@echo "    uc-re              Deploy RE Only"
	@echo "    uc-re-delete       Delete RE Only"
	@echo "    uc-re-ce           Deploy RE to CE"
	@echo "    uc-re-ce-delete    Delete RE to CE"
	@echo "    uc-bigip           Deploy RE to CE via BIG-IP"
	@echo "    uc-bigip-delete    Delete RE to CE via BIG-IP"
	@echo "    uc-clb             Deploy CE via CLB"
	@echo "    uc-clb-delete      Delete CE via CLB"
	@echo "    uc-ce2ce           Deploy CE to CE"
	@echo "    uc-ce2ce-delete    Delete CE to CE"
	@echo "    uc-k8s             Deploy k8s Service Discovery"
	@echo "    uc-k8s-delete      Delete k8s Service Discovery"
	@echo "    uc-vk8s            Deploy vk8s"
	@echo "    uc-vk8s-delete     Delete vk8s"
	@echo ""
	@echo "  USE CASES — SERVICES"
	@echo "    svc-mtls           Deploy TLS Authentication (mTLS)"
	@echo "    svc-mtls-delete    Delete TLS Authentication"
	@echo "    svc-jwt            Deploy JWT Validation"
	@echo "    svc-jwt-delete     Delete JWT Validation"
	@echo ""
	@echo "  UTILITIES"
	@echo "    show-hosts         Print /etc/hosts entries (for copy/paste)"
	@echo "    status             Show Terraform outputs (IPs, CE names)"
	@echo "    check-ip           Compare current public IP with config"
	@echo "    xc-cleanup         Check for orphaned xC objects"
	@echo "    clean              Remove generated payload + cert files"
	@echo "    lint               Run shellcheck + tflint + terraform validate"
	@echo "    docs               Open lab guide in browser"
	@echo ""
	@echo "  ══════════════════════════════════════════════"
	@echo ""

# ─────────────────────────────────────────────────────
# BASICS
# ─────────────────────────────────────────────────────
.PHONY: install
install:
	@$(SETUP_INIT)/bin/initialize.sh init

.PHONY: delete
delete:
	@$(SETUP_INIT)/bin/delete.sh

.PHONY: update-creds
update-creds:
	@$(SETUP_INIT)/bin/initialize.sh update-creds

.PHONY: update-ip
update-ip:
	@$(SETUP_INIT)/bin/initialize.sh update-ip

.PHONY: generate-ca
generate-ca:
	@$(SETUP_INIT)/bin/initialize.sh generate-ca

# ─────────────────────────────────────────────────────
# SSH
# ─────────────────────────────────────────────────────
.PHONY: ssh
ssh:
	@chmod +x $(SSH_SCRIPT) && $(SSH_SCRIPT) all

.PHONY: ssh-central
ssh-central:
	@chmod +x $(SSH_SCRIPT) && $(SSH_SCRIPT) central

.PHONY: ssh-west
ssh-west:
	@chmod +x $(SSH_SCRIPT) && $(SSH_SCRIPT) west

.PHONY: ssh-ubuntu
ssh-ubuntu:
	@chmod +x $(SSH_SCRIPT) && $(SSH_SCRIPT) ubuntu

.PHONY: ssh-bigip
ssh-bigip:
	@chmod +x $(SSH_SCRIPT) && $(SSH_SCRIPT) bigip

# ─────────────────────────────────────────────────────
# USE CASES — ARCHITECTURE
# ─────────────────────────────────────────────────────
.PHONY: uc-re
uc-re:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-only/bin/setup.sh

.PHONY: uc-re-delete
uc-re-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-only/bin/delete.sh

.PHONY: uc-re-ce
uc-re-ce:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-to-CE/bin/setup.sh

.PHONY: uc-re-ce-delete
uc-re-ce-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-to-CE/bin/delete.sh

.PHONY: uc-bigip
uc-bigip:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-to-CE-bigip/bin/setup.sh

.PHONY: uc-bigip-delete
uc-bigip-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/RE-to-CE-bigip/bin/delete.sh

.PHONY: uc-clb
uc-clb:
	@$(REPO_ROOT)/xC-use-cases/Architecture/CE-via-CLB/bin/setup.sh

.PHONY: uc-clb-delete
uc-clb-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/CE-via-CLB/bin/delete.sh

.PHONY: uc-ce2ce
uc-ce2ce:
	@$(REPO_ROOT)/xC-use-cases/Architecture/CE-to-CE/bin/setup.sh

.PHONY: uc-ce2ce-delete
uc-ce2ce-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/CE-to-CE/bin/delete.sh

.PHONY: uc-k8s
uc-k8s:
	@$(REPO_ROOT)/xC-use-cases/Architecture/k8s-service-discovery/bin/setup.sh

.PHONY: uc-k8s-delete
uc-k8s-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/k8s-service-discovery/bin/delete.sh

.PHONY: uc-vk8s
uc-vk8s:
	@$(REPO_ROOT)/xC-use-cases/Architecture/vk8s/bin/setup.sh

.PHONY: uc-vk8s-delete
uc-vk8s-delete:
	@$(REPO_ROOT)/xC-use-cases/Architecture/vk8s/bin/delete.sh

# ─────────────────────────────────────────────────────
# USE CASES — SERVICES
# ─────────────────────────────────────────────────────
.PHONY: svc-mtls
svc-mtls:
	@$(REPO_ROOT)/xC-use-cases/Services/tls-authentication/bin/setup.sh

.PHONY: svc-mtls-delete
svc-mtls-delete:
	@$(REPO_ROOT)/xC-use-cases/Services/tls-authentication/bin/delete.sh

.PHONY: svc-jwt
svc-jwt:
	@$(REPO_ROOT)/xC-use-cases/Services/jwt-validation/bin/setup.sh

.PHONY: svc-jwt-delete
svc-jwt-delete:
	@$(REPO_ROOT)/xC-use-cases/Services/jwt-validation/bin/delete.sh

# ─────────────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────────────
.PHONY: show-hosts
show-hosts:
	@terraform -chdir=$(INFRA) output -raw etc-hosts

.PHONY: status
status:
	@echo ""
	@echo "  CE EU-Central:  $$(terraform -chdir=$(INFRA) output -raw xC-MCN-CE-EU-CENTRAL1 2>/dev/null || echo 'n/a')"
	@echo "  CE EU-West:     $$(terraform -chdir=$(INFRA) output -raw xC-MCN-CE-EU-WEST1 2>/dev/null || echo 'n/a')"
	@echo "  GW01 Central:   $$(terraform -chdir=$(INFRA) output -raw xC-MCN-CE-EU-CENTRAL1-GW01 2>/dev/null || echo 'n/a')"
	@echo "  GW01 West:      $$(terraform -chdir=$(INFRA) output -raw xC-MCN-CE-EU-WEST1-GW01 2>/dev/null || echo 'n/a')"
	@echo ""

.PHONY: check-ip
check-ip:
	@CURRENT=$$(curl -s https://checkip.amazonaws.com | tr -d '\n'); \
	STORED=$$(yq '.student."ip-address"' $(SETUP_INIT)/config.yaml 2>/dev/null | sed 's|/32||'); \
	echo "  Current public IP: $$CURRENT"; \
	echo "  Config IP:         $$STORED"; \
	if [ "$$CURRENT" = "$$STORED" ]; then \
		echo "  Status:            ✓ match"; \
	else \
		echo "  Status:            ✗ mismatch — run 'make update-ip'"; \
	fi

.PHONY: xc-cleanup
xc-cleanup:
	@$(REPO_ROOT)/tools/xc-cleanup/bin/check-objects.sh

.PHONY: clean
clean:
	@echo "Removing generated payload and cert files..."
	@find $(REPO_ROOT)/xC-use-cases -name "payload_final_*.json" -delete 2>/dev/null; true
	@find $(REPO_ROOT)/setup-init/.cert/domains -name "*.cert" -o -name "*.key" 2>/dev/null | xargs rm -f 2>/dev/null; true
	@rm -f $(REPO_ROOT)/tools/s-certificate/config/config.yaml 2>/dev/null; true
	@echo "Done."

.PHONY: lint
lint:
	@echo "--- shellcheck ---"
	@shellcheck $(SETUP_INIT)/**/*.sh $(REPO_ROOT)/xC-use-cases/**/bin/*.sh 2>/dev/null || true
	@echo "--- tflint ---"
	@tflint --recursive --chdir=$(INFRA) 2>/dev/null || true
	@echo "--- terraform validate ---"
	@terraform -chdir=$(INFRA) validate

.PHONY: docs
docs:
	@open $(REPO_ROOT)/docs/lab-guide/index.html 2>/dev/null || \
	 xdg-open $(REPO_ROOT)/docs/lab-guide/index.html 2>/dev/null || \
	 echo "Open manually: $(REPO_ROOT)/docs/lab-guide/index.html"
