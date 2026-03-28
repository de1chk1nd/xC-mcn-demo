# xC-mcn-demo

Lab/demo environment for F5 Distributed Cloud (xC) Multi-Cloud Networking (MCN). Provisions AWS infrastructure in two regions with CE nodes, BIG-IP appliances, and Ubuntu web servers. Demonstrates hybrid cloud connectivity, multi-cloud networking, and WAAP use cases.

> **[Lab Guide](docs/lab-guide/index.html)** — Interactive single-page guide with setup, use cases, and tests
>
> **[Tech Docs](xC-use-cases/README.md)** — Technical documentation for all use cases, API endpoints, and scripts

---

## Overview

![AWS Lab Overview](docs/images/overview-aws-lab-v3.png)

### Infrastructure

| Component | Region | Description |
|:----------|:-------|:------------|
| Customer Edge (CE) | eu-central-1, eu-west-1 | xC CE nodes with BGP, connected via Transit Gateway |
| Ubuntu Servers | eu-central-1, eu-west-1 | Application workloads (NGINX echo, minikube) |
| BIG-IP | eu-central-1, eu-west-1 | Local traffic management, iRules, APM |
| NLB | eu-central-1, eu-west-1 | AWS Network Load Balancers forwarding to CE/BIG-IP |

### Use Cases

| Category | Use Cases |
|:---------|:----------|
| **Architecture** | RE Only, RE to CE, RE to CE via BIG-IP, CE via CLB, CE to CE, k8s SD, vk8s |
| **Services** | TLS Authentication (mTLS), JWT Validation |
| **Evaluation** | BGP Anycast Routing |

See the [Use Cases Overview](xC-use-cases/README.md) for details, or jump directly into the [Lab Guide](docs/lab-guide/index.html).

---

## Quick Start

```bash
git clone https://github.com/de1chk1nd/xC-mcn-demo.git
cd xC-mcn-demo
cp setup-init/template/config.yaml setup-init/config.yaml
vim setup-init/config.yaml
./setup-init/bin/initialize.sh init
```

For the full setup walkthrough, see the [Lab Guide](docs/lab-guide/index.html).

---

## Project Structure

```
├── infrastructure/       # Terraform IaC (AWS + xC)
├── setup-init/           # Initialization scripts & config
├── xC-use-cases/
│   ├── Architecture/     # Architecture use cases (RE, CE, E-W, SD, vk8s)
│   ├── Services/         # Platform services (mTLS, JWT)
│   └── Evaluation/       # Use cases under evaluation
├── tools/                # Standalone utilities
│   └── s-certificate/    # CA-signed certificate generator
└── docs/
    ├── lab-guide/        # Interactive HTML lab guide
    └── images/           # Architecture diagrams
```

---

## Tools

| Tool | Purpose |
|:-----|:--------|
| **[s-certificate](tools/s-certificate/)** | Generate CA-signed server/client certificates, optional upload to xC |

See [tools/README.md](tools/README.md) for details.

---

## Documentation

| Document | Description |
|:---------|:------------|
| **[Lab Guide](docs/lab-guide/index.html)** | Interactive setup, use cases, and test instructions |
| **[Use Cases](xC-use-cases/README.md)** | Technical docs, API endpoints, script flows |
| **[Installation Guide](docs/install-and-setup.md)** | Prerequisites and detailed setup |
| **[Tools](tools/README.md)** | Standalone utilities |
| **[Contributing](CONTRIBUTING.md)** | How to contribute |
| **[Security Policy](SECURITY.md)** | Credential handling, vulnerability reporting |
| **[License](LICENSE)** | MIT License |
