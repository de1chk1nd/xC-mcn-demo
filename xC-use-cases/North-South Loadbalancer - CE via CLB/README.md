# North-South Loadbalancer - CE via CLB

Create HTTP load balancers with ingress and egress via **Customer Edge (CE)** on AWS. Client sessions are terminated directly at the CE -- either via a public cloud load balancer (CLB) or via internal request on the inside interface. This provides **SaaS-managed local WAAP** without routing through the Regional Edge. A default **Web Application Firewall** policy is attached to each load balancer.

![Use Case - CE via CLB](../../docs/images/use-cases/CE-via-clb.png)

## Prerequisites

- `setup-init/config.yaml` configured with valid XC credentials
- PEM certificate generated (run `python3 setup-init/initialize_infrastructure.py`)
- Infrastructure deployed (`terraform apply` in `infrastructure/`)
- Origin pools `origin-nginx-aws-eu-central-1` and `origin-nginx-aws-eu-west-1` must exist (created by infrastructure Terraform)
- `yq`, `envsubst`, and `curl` installed

## Deploy

```bash
"./xC-use-cases/North-South Loadbalancer - CE via CLB/bin/setup.sh"
```

This script will:
1. Generate load balancer payloads from templates
2. Create HTTP load balancer `lb-ce-central` (advertised on eu-central CE sites)
3. Create HTTP load balancer `lb-ce-west` (advertised on eu-west CE sites)

## Test Access

### Via public Cloud Load Balancer (external)

Access the NLB FQDN from your browser or curl. Requires local `/etc/hosts` entries (see Post Install in main README).

| Region | App | App + XSS test |
|:---|:---|:---|
| EU-Central-1 | `http://app-1.eu-central-1.de1chk1nd-lab.aws` | `http://app-1.eu-central-1.de1chk1nd-lab.aws?a=<script>` |
| EU-West-1 | `http://app-1.eu-west-1.de1chk1nd-lab.aws` | `http://app-1.eu-west-1.de1chk1nd-lab.aws?a=<script>` |

### Via inside interface (internal)

SSH to a local Ubuntu jump host and test the internal load balancer:

1. SSH to a web server

```bash
"./xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" central
"./xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" west
"./xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" both
```

2. issue curl commands

```bash
# Normal request -- should return the NGINX server address
curl --silent http://local-web.de1chk1nd-mcn.aws | grep "Server address"

# XSS test -- WAF should block this request
curl --silent "http://local-web.de1chk1nd-mcn.aws?a=<script>"
```

## Delete

```bash
"./xC-use-cases/North-South Loadbalancer - CE via CLB/bin/delete.sh"
```

This script will:
1. Delete both HTTP load balancers
2. Clean up generated payload files

## Configuration

All credentials and tenant settings are loaded from `setup-init/config.yaml` via the shared config loader. No passwords are hardcoded in the scripts.

### Files

| Path | Description |
|------|-------------|
| `bin/setup.sh` | Automated deployment script |
| `bin/delete.sh` | Automated teardown script |
| `etc/__template_lb-ce-eu-central.json` | LB template -- eu-central |
| `etc/__template_lb-ce-eu-west.json` | LB template -- eu-west |
