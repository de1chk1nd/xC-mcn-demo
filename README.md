# xC-mcn-demo

Lab/demo environment for F5 Distributed Cloud (xC) Multi-Cloud Networking (MCN). Pre-configured and prepared to be built in AWS within a couple of minutes.

> **[Lab Guide](docs/lab-guide/index.html)** — Interactive single-page guide with setup, use cases, and tests
>
> **[Tech Docs](xC-use-cases/README.md)** — Technical documentation for all use cases, API endpoints, and scripts

---

## Overview

This lab provisions AWS infrastructure in two regions (eu-central-1, eu-west-1) with **F5 Distributed Cloud Customer Edge (CE)** nodes. The environment is divided into a **Main VPC** and an **App VPC**, interconnected via a **Transit Gateway (TGW)**.

The installation is based on a local Python script that deploys the entire infrastructure. Once deployed, use-case scripts automate the creation of xC load balancers, service discovery, and security services via the xC API.

![AWS Lab Overview](docs/images/overview-aws-lab-v3.png)

### Components

- **Customer Edge (CE)**: Deployed in both the public subnet and transfer TGW subnet. Supports routing and connectivity testing. Uses BGP to communicate with the App VPC.
- **Ubuntu Servers**: Host application workloads (NGINX echo, minikube). Deployed in both the Main VPC and the App VPC. Accessible locally or remotely via BGP routing.
- **BIG-IP Appliances**: Local traffic management with iRules and APM. Supports routing between CE nodes and application servers.
- **Network Load Balancers (NLBs)**: Distribute incoming traffic to CE nodes and BIG-IP instances across different subnets.

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

This architecture showcases flexible traffic routing, high availability, and hybrid connectivity use cases using F5 Distributed Cloud and AWS components. The servers are accompanied by AWS services such as NLB, Route 53 (private hosted zone), and NAT Gateway.

> **Note:** For simplicity, all components are deployed within a single Availability Zone per region.

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
| **[Repository Reference](docs/install-and-setup.md)** | Directory structure, prerequisites, technology stack |
| **[Tools](tools/README.md)** | Standalone utilities |
| **[Contributing](CONTRIBUTING.md)** | How to contribute |
| **[Security Policy](SECURITY.md)** | Credential handling, vulnerability reporting |
| **[License](LICENSE)** | MIT License |
