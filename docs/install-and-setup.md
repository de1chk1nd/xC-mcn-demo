# Repository Reference

Technical reference for the xC-mcn-demo repository. For setup instructions, see the [Lab Guide](lab-guide/index.html).

---

## Directory Structure

```
xC-mcn-demo/
├── infrastructure/                        # Terraform — core AWS + xC infrastructure
│   ├── provider.tf                        #   Provider configuration
│   ├── variables.tf                       #   Input variables (AMI IDs, etc.)
│   ├── site_module.tf                     #   Module invocation per AWS region
│   ├── ssh.tf                             #   SSH key generation
│   ├── vsite.tf                           #   xC Virtual Site definition
│   ├── labels.tf                          #   xC labels / tags
│   ├── app-firewall.tf                    #   xC Web Application Firewall policy
│   ├── outputs.tf                         #   Terraform outputs (IPs, hostnames)
│   └── modules/regions/                   #   Per-region module (eu-central-1, eu-west-1)
│       ├── vpc.tf                         #     VPC definitions
│       ├── subnets.tf                     #     Subnet layout
│       ├── internet-gateway.tf            #     Internet Gateway
│       ├── nat-gateway.tf                 #     NAT Gateway
│       ├── routing-tables.tf              #     Route tables
│       ├── route-table-association.tf     #     Route table associations
│       ├── transitgateway.tf              #     AWS Transit Gateway
│       ├── security-group.tf              #     Security groups
│       ├── nacl.tf                        #     Network ACLs
│       ├── prefix-lists.tf               #     Managed prefix lists
│       ├── nlb.tf                         #     Network Load Balancers
│       ├── route53.tf                     #     Private hosted zone + DNS records
│       ├── ssh.tf                         #     SSH key pair for EC2
│       ├── srv-nginx_main-vpc.tf          #     Ubuntu servers (Main VPC)
│       ├── srv-nginx_app-vpc.tf           #     Ubuntu servers (App VPC)
│       ├── bigip.tf                       #     BIG-IP instances + secrets
│       ├── xc_Gateway.tf                  #     xC Customer Edge gateway nodes
│       ├── xC_origin-pool.tf              #     xC origin pools
│       ├── variables.tf                   #     Module input variables
│       ├── provider.tf                    #     Module provider config
│       ├── outputs.tf                     #     Module outputs
│       └── etc/                           #     Cloud-init templates
│
├── setup-init/                            # Initialization scripts & credentials
│   ├── bin/                               #   Shell entry points (initialize.sh, delete.sh)
│   ├── src/setup_init/                    #   Python initialization package
│   ├── lib/common-config-loader.sh        #   Shared config loader for use-case scripts
│   ├── template/config.yaml               #   Template for config.yaml
│   ├── config.yaml                        #   * User config (gitignored)
│   ├── .xC/                               #   * xC API credentials (gitignored)
│   ├── .cert/                             #   * Generated certificates (gitignored)
│   │   ├── ca/                            #       CA key + cert + serial
│   │   └── domains/                       #       Server + client certs (per use case)
│   └── .ssh/                              #   SSH helper scripts (Linux, macOS, Windows)
│
├── xC-use-cases/                          # Use case scripts & configurations
│   ├── Architecture/                      #   Architecture use cases
│   │   ├── RE-only/                       #     RE-only (SaaS) load balancing
│   │   ├── RE-to-CE/                      #     RE ingress, CE egress
│   │   ├── RE-to-CE-bigip/                #     RE → CE → BIG-IP
│   │   ├── CE-via-CLB/                    #     CE direct via cloud LB
│   │   ├── CE-to-CE/                      #     Cross-region CE-to-CE (east-west)
│   │   ├── k8s-service-discovery/         #     K8s service discovery via kubeconfig
│   │   └── vk8s/                          #     Virtual K8s edge computing
│   ├── Services/                          #   Platform services
│   │   ├── tls-authentication/            #     mTLS with client cert auth + service policy
│   │   └── jwt-validation/                #     JWT validation (RS256, blocking mode)
│   └── Evaluation/                        #   Use cases under evaluation
│       └── bgp-anycast-routing/           #     BGP peering with CE nodes via FRR
│
├── tools/                                 # Standalone utilities
│   └── s-certificate/                     #   CA-signed certificate generator + xC upload
│
├── docs/                                  # Documentation
│   ├── lab-guide/                         #   Interactive HTML lab guide
│   ├── images/                            #   Architecture diagrams and screenshots
│   └── install-and-setup.md               #   This file
│
├── .gitignore                             # Git ignore rules
├── .pre-commit-config.yaml                # Pre-commit hooks (secrets, formatting)
├── AGENTS.md                              # AI agent instructions
├── CONTRIBUTING.md                        # Contribution guidelines
├── SECURITY.md                            # Security policy
├── LICENSE                                # MIT License
└── README.md                              # Project overview
```

> Files and directories marked with `*` are gitignored and must be created locally.

---

## Technology Stack

| Component | Technology | Version / Notes |
|:----------|:-----------|:----------------|
| IaC | Terraform + Volterra Provider | >= 1.x, volterra 0.11.42 |
| Cloud | AWS | 2 regions (eu-central-1, eu-west-1), Transit Gateway |
| Shell | Bash | POSIX-compatible, `set -e` / `set -euo pipefail` |
| Python | Python 3 | >= 3.9, PyYAML, requests |
| Secrets | AWS Secrets Manager | Never in Git |

---

## Prerequisites

### Required Tools

| Tool | Min. Version | Purpose |
|:-----|:-------------|:--------|
| **Terraform** | >= 1.0 | Infrastructure provisioning |
| **Python 3** | >= 3.9 | Deployment scripts, CA generation |
| **yq** | >= 4.x | YAML parsing in shell scripts |
| **curl** | any | xC API calls |
| **openssl** | any | Certificate generation |
| **git** | any | Repository root detection |

### Required Python Packages

| Package | Purpose |
|:--------|:--------|
| **PyYAML** | Parse `config.yaml` |
| **requests** | Public IP detection during init |

### Required Accounts & Credentials

| Credential | Location | Purpose |
|:-----------|:---------|:--------|
| AWS Access Keys (or STS) | `setup-init/config.yaml` | AWS provisioning |
| F5 xC API Certificate (.p12) | `setup-init/.xC/` | xC API authentication |
| F5 xC Tenant | `setup-init/config.yaml` | xC Console endpoint |

---

## Estimated Deployment Times

| Process | Time | Notes |
|:--------|:-----|:------|
| Terraform | 2-3 min | Core infrastructure |
| BIG-IP vAppliances | 5-7 min | Wait for AS3 to complete L4-L7 services |
| xC Gateway (CE) | 15-20 min | Check xC Console for "online" status |

---

## Configuration Reference

The `setup-init/config.yaml` file controls all deployment parameters. Copy from template before first use:

```shell
cp setup-init/template/config.yaml setup-init/config.yaml
```

See the **[Parameter Reference](../setup-init/template/PARAMETERS.md)** for a detailed description of every field.

Key points:
- AWS credentials can be set in the file **or** via environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) — env vars take priority
- `tenant_api` and `tenant_shrt` are auto-derived from `tenant` — no manual input needed
- `tenant_anycast_ip` is auto-fetched from the xC API — set manually only to override with a secondary IP
- Terraform uses the AWS profile defined in `config.yaml` (default: `xc-mcn-lab`)

---

## Pre-commit Hooks

The repository uses pre-commit hooks for quality and security:

```shell
pip install pre-commit
pre-commit install
```

| Hook | Purpose |
|:-----|:--------|
| gitleaks | Secret scanning |
| detect-private-key | Prevent private key commits |
| shellcheck | Shell script linting |
| terraform_fmt | Terraform formatting |
| terraform_validate | Terraform validation |
