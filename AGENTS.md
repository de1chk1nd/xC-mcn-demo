# Project Agent Instructions — xC-mcn-demo
# Scope: Repo root → applies to the entire repository
# Type: Single large project (Terraform + Shell + Python)
# Token budget: max. 80 lines of active content

---

## Project Overview

Lab/demo environment for F5 Distributed Cloud (xC) Multi-Cloud Networking (MCN).
Provisions AWS infrastructure in two regions (eu-central-1, eu-west-1) with CE nodes, BIG-IP appliances, and Ubuntu web servers.
Demonstrates hybrid cloud connectivity, multi-cloud networking, and WAAP use cases.
Target environment: lab / demo — not production.

---

## Repo Structure

```
.
├── infrastructure/       # Terraform IaC — AWS + xC infrastructure
│   └── modules/regions/  # Per-region module (VPC, CE, BIG-IP, servers)
├── setup-init/           # Initialization scripts & credentials
│   ├── bin/              # Shell entry points (initialize.sh, delete.sh)
│   ├── src/setup_init/   # Python initialization package
│   ├── lib/              # Shared shell libraries for use-cases
│   ├── template/         # config.yaml template
│   ├── .cert/            # Generated certificates (gitignored)
│   │   ├── ca/           #   CA key + cert + serial
│   │   └── domains/      #   Server + client certs (per use case)
│   ├── .ssh/             # SSH helper scripts (Linux, macOS, Windows)
│   └── .xC/              # xC API certs (gitignored)
├── tools/                # Standalone utilities
│   └── s-certificate/    # CA-signed certificate generator + xC upload
├── xC-use-cases/         # Use-case deployment scripts (curl → xC API)
│   ├── Architecture/     # Architecture use cases
│   │   ├── RE-only/      #   RE-only load balancing
│   │   ├── RE-to-CE/     #   RE ingress, CE egress
│   │   ├── RE-to-CE-bigip/ # RE → CE → BIG-IP
│   │   ├── CE-via-CLB/   #   CE direct via cloud LB (NLB)
│   │   ├── CE-to-CE/     #   Cross-region east-west
│   │   ├── k8s-service-discovery/ # K8s SD via kubeconfig
│   │   └── vk8s/         #   Virtual K8s edge computing
│   ├── Services/         # Platform services (mTLS, JWT, etc.)
│   │   ├── tls-authentication/  # mTLS with client cert auth + service policy
│   │   └── jwt-validation/      # JWT validation (RS256, blocking mode)
│   └── Evaluation/       # Use cases under evaluation
│       └── bgp-anycast-routing/ # BGP peering with CE nodes via FRR
└── docs/                 # Documentation, diagrams & lab guide
    ├── images/           # Architecture & use-case diagrams
    └── lab-guide/        # Interactive single-page lab guide (HTML)
```

---

## Technology Stack

| Component   | Technology                      | Version / Notes              |
|-------------|---------------------------------|------------------------------|
| IaC         | Terraform + Volterra Provider   | >= 1.x, volterra 0.11.42     |
| Cloud       | AWS                             | 2 regions, Transit Gateway   |
| Shell       | Bash                            | POSIX-compatible             |
| Python      | Python 3                        | >= 3.9, PyYAML, requests     |
| Secrets     | AWS Secrets Manager             | never in Git                 |

---

## Key Commands

The repo includes a **Makefile** in the root directory as the primary entry point.
Use `make` or `make help` to see all available targets.

```bash
# ─── Basics ───────────────────────────────────────
make install           # Full lab init (Terraform + xC)
make delete            # Destroy all infrastructure
make update-creds      # Update AWS credentials (after STS rotation)
make update-ip         # Update public IP + refresh Security Groups [BETA]
make generate-ca       # Generate CA only

# ─── SSH ──────────────────────────────────────────
make ssh               # Open SSH to all servers (OS auto-detected)
make ssh-central       # SSH to eu-central only
make ssh-west          # SSH to eu-west only
make ssh-ubuntu        # SSH to Ubuntu servers
make ssh-bigip         # SSH to BIG-IP servers

# ─── Use Cases ────────────────────────────────────
make uc-re             # Deploy RE Only (+ make uc-re-delete)
make uc-re-ce          # Deploy RE to CE (+ make uc-re-ce-delete)
make uc-bigip          # Deploy RE to CE via BIG-IP (+ delete)
make uc-clb            # Deploy CE via CLB (+ delete)
make uc-ce2ce          # Deploy CE to CE (+ delete)
make uc-k8s            # Deploy k8s SD (+ delete)
make uc-vk8s           # Deploy vk8s (+ delete)
make svc-mtls          # Deploy mTLS (+ make svc-mtls-delete)
make svc-jwt           # Deploy JWT Validation (+ delete)

# ─── Utilities ────────────────────────────────────
make show-hosts        # Print /etc/hosts entries
make status            # Show Terraform outputs (IPs, CE names)
make check-ip          # Compare current IP with config
make xc-cleanup        # Check for orphaned xC objects (read-only)
make clean             # Remove generated payloads + certs
make lint              # shellcheck + tflint + terraform validate
make docs              # Open lab guide in browser

# ─── Direct access (if preferred over make) ───────
./setup-init/bin/initialize.sh init
./setup-init/bin/initialize.sh update-creds
./setup-init/bin/initialize.sh update-ip
./setup-init/bin/initialize.sh generate-ca
./setup-init/bin/delete.sh

# Linting
make lint
# or directly:
tflint --recursive
shellcheck setup-init/**/*.sh xC-use-cases/**/bin/*.sh

# Tools — s-certificate (key flags: --no-p12, --keep-pem, --xc-upload)
cd tools/s-certificate && ./bin/run-s-certificate.sh --help

# Tools — xc-cleanup (check for orphaned xC objects)
make xc-cleanup
# or directly:
./tools/xc-cleanup/bin/check-objects.sh

# Documentation — Lab Guide (open in browser)
open docs/lab-guide/index.html
```

---

## Conventions & Rules

- Terraform: tag all resources with `environment` and `owner`
- Never suggest `terraform apply` without a prior `plan` review
- Shell scripts: start with `set -euo pipefail` (init/tools) or `set -e` (use-case scripts)
- Sensitive variables: document in `*.example`, never commit real values
- Tools: each tool lives in `tools/<name>/` with own README, bin/, src/, config/
- CA: auto-generated during init, stored in `setup-init/.cert/ca/`, gitignored

### Cross-Platform Compatibility (macOS + Linux)

**All scripts, tools, and Python code must work on both macOS and Linux.**
This is a hard requirement — not optional. Test on both platforms when possible.

Known differences to watch for:

| Area | macOS | Linux | Safe Pattern |
|------|-------|-------|-------------|
| `base64` | No line wrapping | Wraps at 76 chars | Always `base64 < file \| tr -d '\n'` |
| `base64` arg | `base64 file` may not work | `base64 file` works | Always `base64 < file` (stdin redirect) |
| `sed -i` | Requires `sed -i ''` (empty backup ext) | `sed -i` works without arg | Avoid `sed -i` in shared scripts; use Python or `ed` |
| `grep -o` | POSIX behavior | GNU extensions available | Stick to POSIX-compatible patterns |
| `openssl` | LibreSSL (older, quirks) | OpenSSL (full features) | Test both; `-CAcreateserial` writes to CWD on macOS |
| Terminal | Terminal.app, iTerm2 | gnome-terminal, xfce4, etc. | OS-specific scripts (`_mac.sh`, `_lnx.sh`) |
| `readlink -f` | Not available | Works | Use `git rev-parse --show-toplevel` or `cd && pwd` |
| Heredoc + base64 | No issues with short strings | Newlines in base64 break heredoc | Always strip newlines from base64 before embedding in heredoc |
| `date` | BSD date (different flags) | GNU date | Avoid platform-specific date flags; use Python for formatting |
| Python | `python3` (Homebrew or system) | `python3` (apt/yum) | Always use `python3`, never `python` |

**General rules:**
- Always use `base64 < file | tr -d '\n'` — never `base64 file` without redirect
- Always use `#!/usr/bin/env bash` — never `#!/bin/bash` with hardcoded paths
- Always pipe `openssl` serial files explicitly (`-CAserial <path>`) — never rely on CWD
- Always test shell scripts with `bash -n <script>` before committing
- For complex text manipulation, prefer Python over `sed`/`awk` for portability

---

## Tools Convention

New tools go into `tools/<tool-name>/` with this structure:
```
tools/<tool-name>/
├── bin/              # Shell entry points
├── src/              # Source code
├── config/           # *.example tracked, real configs gitignored
├── docs/             # Tool-specific docs
├── README.md
└── requirements.txt  # Dependencies (Python)
```

---

## Initialization Convention

Setup scripts follow this structure:
```
setup-init/
├── bin/              # Shell entry points (initialize.sh, delete.sh)
├── src/setup_init/   # Python package with modular components
│   ├── cli.py        # CLI orchestration
│   ├── config.py     # Configuration loading/saving
│   ├── aws.py        # AWS credential management
│   ├── ca.py         # CA generation
│   ├── terraform.py  # Terraform wrapper
│   ├── xc.py         # xC certificate handling
│   └── network.py    # Public IP detection
├── lib/              # Shared shell libraries for use-cases
└── template/         # Config templates (tracked)
```

---

## Use-Case TLS Workflow

Use-case `setup.sh` scripts generate CA-signed server certificates (not Let's Encrypt).
Each script follows this sequence:

1. Ensure `tools/s-certificate/config/config.yaml` exists (copy from `.example` if missing)
2. Generate server cert via `s-certificate --no-p12 --keep-pem` → PEM files in `setup-init/.cert/domains/`
3. Base64-encode cert + key, upload to xC via `POST /api/config/namespaces/{ns}/certificates`
4. Generate LB payloads from templates (`envsubst`) — templates reference the cert via `tls_cert_params`
5. Create origin pools + HTTP load balancers via xC API

Corresponding `delete.sh` scripts reverse the process: delete LBs, delete cert objects from xC, remove local PEM files.

**Cert naming convention:** `tls-${STUDENT}-<host-part-of-fqdn>` (e.g. `tls-jdoe-echo-public`)

### mTLS Workflow (Services/tls-authentication)

The mTLS service extends the standard TLS workflow with client certificate authentication:

1. Generate server cert via `s-certificate` (same as standard workflow)
2. Generate **client certificates** via `openssl` directly (not s-certificate) — each user needs a unique email/CN
3. Upload lab CA as `trusted_ca_list` object (`POST .../trusted_ca_lists`)
4. Create HTTP LB with `use_mtls` block (references `trusted_ca_list`, configures XFCC header injection)
5. Create **service policy** (`POST .../service_policys`) matching XFCC header for cert-based access control
6. Service policy must be **manually assigned** to the LB in xC Console

The CA must have `basicConstraints = CA:TRUE` for xC to accept it as a trusted CA.

### JWT Workflow (Services/jwt-validation)

The JWT service uses the lab CA private key to sign tokens (RS256):

1. Generate server cert via `s-certificate` (same as standard workflow)
2. Generate JWT tokens + JWKS via `generate-tokens.py` using the **lab CA private key** for RS256 signing
3. Base64-encode JWKS, embed inline in LB template via `jwks_config.cleartext` (`string:///` prefix)
4. Create HTTP LB with `jwt_validation` block (blocking mode, RS256, issuer + audience claims)

Token claims validated: `iss` (issuer), `aud` (audience), `sub` (subject), `exp` (expiration).

---

## SSH Helper Scripts

Platform-specific scripts in `setup-init/.ssh/`:

| Script | Platform | Terminal support |
|--------|----------|-----------------|
| `ssh-key-permission_lnx.sh` | Linux | gnome-terminal, xfce4, konsole, terminator |
| `ssh-key-permission_mac.sh` | macOS | Terminal.app, iTerm2 |

All scripts accept a target argument: `all`, `ubuntu`, `bigip`, `central`, `west`, `fix-perms`.
The `known_hosts` cleanup removes only lab hosts (`*.${STUDENT}.xc-mcn-lab.aws`), preserving other entries.

---

## Known Pitfalls

- Never suggest `terraform destroy` without explicit confirmation
- xC API calls require valid certs in `setup-init/.xC/` — gitignored
- CA is generated once per lab instance in `setup-init/.cert/ca/` — gitignored
- Server/client certs go to `setup-init/.cert/domains/` — gitignored
- Tools generate artifacts (ca/, domains/, venv/) — all gitignored
- Domain suffix is dynamized via `local.domain_suffix` = `${var.student}.xc-mcn-lab.aws`
- Use-case JSON templates use `${STUDENT}` (resolved by `envsubst` at runtime)
- CA must exist before running any use-case setup.sh (`initialize.sh init` or `generate-ca`)
- Use-case scripts require `s-certificate --keep-pem` — without it, PEM files are deleted before upload
- Certs are CA-signed (not public CA) — browsers show TLS warnings unless lab CA is trusted
- SSH scripts are OS-specific: `_mac.sh` for macOS, `_lnx.sh` for Linux — choose the correct one
- SSH `known_hosts` cleanup is selective — only `*.${STUDENT}.xc-mcn-lab.aws` entries are removed
- JWT tokens are RS256-signed with the lab CA private key — same key used for TLS and JWT signing
- `base64` encoding: always use `base64 < file` (stdin redirect), not `base64 file` — behavior differs on macOS vs Linux
