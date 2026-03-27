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
│   ├── lib/              # Shared shell libraries
│   ├── template/         # config.yaml template
│   ├── .cert/            # Generated certificates (gitignored)
│   │   ├── ca/           #   CA key + cert
│   │   └── domains/      #   Server + client certs
│   └── .xC/              # xC API certs (gitignored)
├── tools/                # Standalone utilities
│   └── s-certificate/    # CA-signed certificate generator + xC upload
├── xC-use-cases/         # Use-case deployment scripts (curl → xC API)
│   └── */bin/            # setup.sh / delete.sh per use case
└── docs/                 # Architecture documentation & diagrams
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

# Tools — s-certificate
cd tools/s-certificate && ./bin/run-s-certificate.sh --help

# Documentation — Lab Guide (open in browser)
open docs/lab-guide/index.html
```

---

## Conventions & Rules

- Terraform: tag all resources with `environment` and `owner`
- Never suggest `terraform apply` without a prior `plan` review
- Shell scripts: always start with `set -euo pipefail`
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

## Known Pitfalls

- Never suggest `terraform destroy` without explicit confirmation
- xC API calls require valid certs in `setup-init/.xC/` — gitignored
- CA is generated once per lab instance in `setup-init/.cert/ca/` — gitignored
- Server/client certs go to `setup-init/.cert/domains/` — gitignored
- Tools generate artifacts (ca/, domains/, venv/) — all gitignored
- Domain suffix is dynamized via `local.domain_suffix` = `${var.student}.xc-mcn-lab.aws`
- Use-case JSON templates use `${STUDENT}` (resolved by `envsubst` at runtime)
