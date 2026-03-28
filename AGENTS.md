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
│   ├── Architecture/     # Architecture use cases (RE, CE, E-W, SD, vk8s)
│   │   └── */bin/        # setup.sh / delete.sh per use case
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

```bash
# Full initialization (CA, AWS creds, Terraform)
./setup-init/bin/initialize.sh init

# Update AWS credentials only (after STS rotation)
./setup-init/bin/initialize.sh update-creds

# Generate CA only
./setup-init/bin/initialize.sh generate-ca

# Teardown
./setup-init/bin/delete.sh

# Linting
tflint --recursive
shellcheck setup-init/**/*.sh xC-use-cases/**/bin/*.sh

# Tools — s-certificate (key flags: --no-p12, --keep-pem, --xc-upload)
cd tools/s-certificate && ./bin/run-s-certificate.sh --help

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

---

## SSH Helper Scripts

Platform-specific scripts in `setup-init/.ssh/`:

| Script | Platform | Terminal support |
|--------|----------|-----------------|
| `ssh-key-permission_lnx.sh` | Linux | gnome-terminal, xfce4, konsole, terminator |
| `ssh-key-permission_mac.sh` | macOS | Terminal.app, iTerm2 |
| `ssh-key-permission_win.ps1` | Windows | WinSCP + PuTTY |

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
