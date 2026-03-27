# Installation, Setup & Repository Reference

This document covers everything you need to get started: prerequisites, tool installation, repository structure, and detailed setup instructions.

&nbsp;

---

## Table of Contents

- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
  - [Required Tools](#required-tools)
  - [Required Python Packages](#required-python-packages)
  - [Required Accounts & Credentials](#required-accounts--credentials)
  - [Optional Tools](#optional-tools)
  - [Quick Install (Ubuntu/Debian)](#quick-install-ubuntudebian)
  - [Quick Install (macOS)](#quick-install-macos)
- [Installation](#installation)
- [Post Install](#post-install)
- [Delete / Teardown](#delete--teardown)

&nbsp;

---

## Directory Structure

```
xC-mcn-demo/
├── infrastructure/                        # Terraform - core AWS + xC infrastructure
│   ├── provider.tf                        #   Terraform provider configuration
│   ├── variables.tf                       #   Input variables (AMI IDs, etc.)
│   ├── site_module.tf                     #   Module invocation per AWS region
│   ├── ssh.tf                             #   SSH key generation
│   ├── vsite.tf                           #   xC Virtual Site definition
│   ├── labels.tf                          #   xC labels / tags
│   ├── app-firewall.tf                    #   xC Web Application Firewall policy
│   ├── xC_http-loadbalancer.tf            #   xC HTTP load balancer (global)
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
│           ├── ubuntu/ubuntu.tmpl         #       Ubuntu server cloud-init
│           ├── ubuntu/ubuntu_app.tmpl     #       Ubuntu app-vpc cloud-init
│           ├── bigip/user-data.tmpl       #       BIG-IP cloud-init (DO/AS3)
│           └── smsv2/user-data.tmpl       #       xC CE (SMSv2) cloud-init
│
├── setup-init/                            # Initialization scripts & credentials
│   ├── bin/
│   │   ├── initialize.sh                  #   Main initialization script
│   │   └── delete.sh                      #   Full teardown script
│   ├── src/setup_init/                    #   Python initialization package
│   │   ├── cli.py                         #     CLI orchestration
│   │   ├── config.py                      #     Configuration loading
│   │   ├── aws.py                         #     AWS credential management
│   │   ├── ca.py                          #     CA generation
│   │   ├── terraform.py                   #     Terraform wrapper
│   │   ├── xc.py                          #     xC certificate handling
│   │   └── network.py                     #     Network utilities
│   ├── lib/common-config-loader.sh        #   Shared config loader for shell scripts
│   ├── template/config.yaml               #   Template for config.yaml
│   ├── config.yaml                        #   * User config - NOT committed (gitignored)
│   ├── .xC/                               #   * xC API credentials (gitignored)
│   ├── .cert/                             #   * Generated certificates (gitignored)
│   │   ├── ca/                            #       CA key + cert
│   │   └── domains/                       #       Server + client certs
│   └── .ssh/                              #   * SSH keys (gitignored) + permission scripts
│       ├── ssh-key-permission_lnx.sh      #     SSH key permissions + multi-tab SSH
│       └── ssh-key-permission_win.ps1     #     SSH key permissions (Windows)
│
├── tools/                                 # Standalone utilities
│   ├── README.md                          #   Tools overview and conventions
│   └── s-certificate/                     #   CA-signed certificate generator
│       ├── bin/run-s-certificate.sh       #     CLI entry point
│       ├── src/s_certificate/             #     Python package
│       ├── config/                        #     Configuration (*.example)
│       └── docs/REFERENCE.md              #     Technical reference
│
├── xC-use-cases/                          # Use case scripts & configurations
│   ├── README.md                          #   Use case overview and quick reference
│   ├── North-South Loadbalancer - RE/     #   RE-only (SaaS) load balancing
│   ├── North-South Loadbalancer - RE to CE/       #   RE ingress, CE egress
│   ├── North-South Loadbalancer - RE to CE on big-ip/  #   RE → CE → BIG-IP
│   ├── North-South Loadbalancer - CE via CLB/     #   CE direct via cloud LB
│   ├── East-West Loadbalancer - CE to CE/ #   Cross-region CE-to-CE
│   ├── East-West Network Connect/         #   Network Connect (WIP)
│   ├── Service Discovery/                 #   Service discovery use cases
│   │   ├── kubernetes/                    #     K8s service discovery via kubeconfig
│   │   └── bigip/                         #     BIG-IP service discovery (WIP)
│   ├── vk8s/                              #   Virtual K8s edge computing
│   │   ├── bin/                           #     Setup/delete scripts
│   │   ├── etc/                           #     JSON API templates
│   │   └── terraform/                     #     vk8s Terraform config
│   ├── ___WAF-Policy/                     #   WAF policy JSON reference
│   ├── Web Application Scan/              #   OWASP Juice Shop scan reference
│   └── misc/                              #   Additional references
│       ├── mTLS/                           #     Mutual TLS setup + OpenSSL config
│       ├── jwt-validation/                 #     API security - JWT validation
│       └── bgp anycast routing/            #     BGP anycast with FRR
│
├── docs/                                  # Documentation & images
│   ├── install-and-setup.md               #   This file
│   └── images/                            #   Architecture diagrams and screenshots
├── .gitignore                             # Git ignore rules
├── .pre-commit-config.yaml                # Pre-commit hooks (secrets, formatting)
├── LICENSE                                # MIT License
├── CONTRIBUTING.md                        # Contribution guidelines
├── SECURITY.md                            # Security policy
├── AGENTS.md                              # AI agent instructions
└── README.md                              # Project overview
```

> **Note:** Files and directories marked with `*` are gitignored and must be created locally from the templates provided.

&nbsp;

---

## Prerequisites

### Required Tools

| Tool | Min. Version | Used By | Purpose |
|:-----|:-------------|:--------|:--------|
| **Terraform** | >= 1.0 | `infrastructure/`, `vk8s/terraform/` | Infrastructure provisioning |
| **Python 3** | >= 3.9 | `setup-init/src/`, `tools/` | Deployment scripts, CA generation |
| **yq** | >= 4.x | All shell scripts via `common-config-loader.sh` | YAML parsing in shell |
| **curl** | any | Use case `setup.sh` / `delete.sh` scripts | xC API calls |
| **openssl** | any | `setup-init/`, `tools/s-certificate` | Certificate generation and conversion |
| **git** | any | All shell scripts (`git rev-parse`) | Repository root detection |
| **AWS CLI** | >= 2.x | Optional, for manual AWS operations | AWS credential management |

### Required Python Packages

| Package | Import | Purpose |
|:--------|:-------|:--------|
| **PyYAML** | `yaml` | Parse `config.yaml` |
| **requests** | `requests` | Public IP detection during init |

> All other Python imports (`os`, `subprocess`, `configparser`, `pathlib`, `dataclasses`) are part of the standard library.

### Required Accounts & Credentials

| Credential | Location | Purpose |
|:-----------|:---------|:--------|
| **AWS Access Keys** (or STS session) | `setup-init/config.yaml` | AWS infrastructure provisioning |
| **F5 xC API Certificate** (.p12) | `setup-init/.xC/` | xC Terraform provider + API calls |
| **F5 xC Tenant** | `setup-init/config.yaml` | xC Console API endpoint |

### Optional Tools

| Tool | Used By | Purpose |
|:-----|:--------|:--------|
| **xclip** | Post-install `/etc/hosts` copy | Clipboard copy on Linux |
| **ssh** | `ssh-key-permission_lnx.sh`, use case scripts | Remote access to EC2 instances |
| **pre-commit** | `.pre-commit-config.yaml` | Git hook automation (secret scanning, linting) |

&nbsp;

### Quick Install (Ubuntu/Debian)

```shell
# Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# Python 3 + pip
sudo apt install -y python3 python3-pip

# yq (YAML processor - https://github.com/mikefarah/yq)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Other tools
sudo apt install -y curl openssl git xclip

# Pre-commit (optional, recommended for contributors)
pip3 install pre-commit
pre-commit install
```

### Quick Install (macOS)

```shell
# Terraform + tools
brew install terraform python yq curl openssl git pre-commit

# Python packages
# Install via venv after cloning the repo (see below)

# Pre-commit hooks (optional)
pre-commit install
```

### Python Packages (venv)

Use a virtual environment and install from `requirements.txt`:

```shell
cd xC-mcn-demo
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

&nbsp;

---

## Installation

1. Clone the repository and `cd` into the root directory:

    ```shell
    git clone https://github.com/de1chk1nd/xC-mcn-demo.git
    cd xC-mcn-demo
    ```

2. Copy the template configuration and fill in your credentials:

    ```shell
    cp ./setup-init/template/config.yaml ./setup-init/config.yaml
    ```

    Edit `./setup-init/config.yaml` and fill in:
    - `aws.aws_access_key_id`, `aws_secret_access_key`, `aws_session_token`
    - `xC.p12_auth`, `p_12_pwd`, `tenant`, `tenant_shrt`, `tenant_api`, `namespace`
    - `student.name`, `email`

    > **ATTENTION:** Terraform expects (by default) that AWS auth uses the profile `xc-mcn-lab`. This can be changed within the **config.yaml** file.

3. Place your F5 xC API certificate (`.p12` file) into `./setup-init/.xC/`.

4. Run the initialization script:

    ```shell
    ./setup-init/bin/initialize.sh init
    ```

    This will:
    - Detect your public IP address
    - Generate a Certificate Authority (CA) in `./setup-init/.cert/ca/`
    - Update AWS credentials in `~/.aws/credentials`
    - Convert the xC P12 certificate to PEM format
    - Run `terraform fmt`, `init`, `plan`, and `apply`

&nbsp;

- Approximate installation times — must complete before starting the use cases:

    | Process / Device      | Estimated Time      | Comment                                                             |
    |:----------------------|:--------------------|:--------------------------------------------------------------------|
    | Terraform             | ***2-3 minutes***   | ./.                                                                 |
    | BigIP vAppliances     | ***5-7 minutes***   | Check if AS3 completes L4-L7 Services: Pools, vServer in partition  |
    | xC Gateway            | ***15-20 minutes*** | Check within the xC Console if Gateways are "online"                |

&nbsp;

---

## Post Install

Add entries to the local `/etc/hosts` file to resolve FQDNs used in this repository:

```shell
terraform -chdir="./infrastructure" output -raw etc-hosts | xclip -sel clip
x-terminal-emulator -e 'sudo vim /etc/hosts'
```

Fix SSH key permissions, clear known hosts, and open SSH sessions to all lab servers:

```shell
./setup-init/.ssh/ssh-key-permission_lnx.sh all
```

> To only fix permissions without opening SSH sessions, use `./setup-init/.ssh/ssh-key-permission_lnx.sh fix-perms`.
> Other targets: `ubuntu`, `bigip`, `central`, `west`. Run with `--help` for details.

&nbsp;

- ***Access to Devices:***

    | Device              | Username | Password (lab-default)  |
    |:--------------------|:---------|:------------------------|
    | BigIP (each region) | admin    | DefaultLabPwd!2026      |

    > **ATTENTION:** Before you can access the AWS devices, add the local `/etc/hosts` entries first!

&nbsp;

---

## Delete / Teardown

- **Optional:** If AWS credentials have expired, update them in `./setup-init/config.yaml` and run:

    ```shell
    ./setup-init/bin/initialize.sh update-creds
    ```

- Delete infrastructure in AWS and within the xC Console:

    ```shell
    ./setup-init/bin/delete.sh
    ```

- Manually remove local hosts entries:

    ```shell
    sudo vim /etc/hosts
    ```
