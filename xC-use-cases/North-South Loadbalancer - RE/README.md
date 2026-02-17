# North-South Loadbalancer - RE Only

Create an HTTP load balancer with ingress and egress via **Regional Edge (RE)**.

Egress goes directly via the Internet using DNS service discovery (FQDN) of AWS NLB names across EU-Central-1 and EU-West-1.

A default **Web Application Firewall** policy is attached to the load balancer, guaranteeing common security policies and metrics accross different envionments.

![Use Case - RE only](../../docs/images/use-cases/RE-only.png)

## Prerequisites

- `setup-init/config.yaml` configured with valid XC credentials
- PEM certificate generated (run `python3 setup-init/initialize_infrastructure.py`)
- Infrastructure deployed (`terraform apply` in `infrastructure/`)
- `yq`, `envsubst`, and `curl` installed

## Deploy

```bash
"./xC-use-cases/North-South Loadbalancer - RE/bin/setup.sh"
```

This script will:
1. Fetch NLB DNS names from Terraform outputs
2. Generate origin pool and load balancer payloads from templates
3. Create the origin pool `origin-public-echo-aws` via XC API
4. Create the HTTP load balancer `lb-echo-public` via XC API

## Test

Test appliaction access and verify "hostname" in json response.
Loadbalancing between eu-central-1 and eu-west-1.

## Delete

```bash
"./xC-use-cases/North-South Loadbalancer - RE/bin/delete.sh"
```

This script will:
1. Delete the HTTP load balancer
2. Delete the origin pool
3. Clean up generated payload files

## Configuration

All credentials and tenant settings are loaded from `setup-init/config.yaml` via the shared config loader. No passwords are hardcoded in the scripts.

### Files

| Path | Description |
|------|-------------|
| `bin/setup.sh` | Automated deployment script |
| `bin/delete.sh` | Automated teardown script |
| `etc/__template__origin-pool.json` | Origin pool template (uses NLB DNS from Terraform) |
| `etc/__template_http-loadbalancer.json` | HTTP load balancer template |
