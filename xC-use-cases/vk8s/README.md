# vk8s Use Case

Deploy a virtual Kubernetes (vk8s) workload on F5 XC with origin pools and HTTP load balancers across two AWS regions.

## Prerequisites

- `setup-init/config.yaml` configured with valid XC credentials
- PEM certificate generated (run `python3 setup-init/initialize_infrastructure.py`)
- Infrastructure deployed (`terraform apply` in `infrastructure/`)
- `yq`, `envsubst`, `terraform`, and `curl` installed

## Deploy

```bash
./xC-use-cases/vk8s/bin/setup.sh
```

This script will:
1. Create the vk8s cluster via Terraform
2. Deploy the `echo-aws` workload to CE sites
3. Create origin pools for eu-central and eu-west (from templates using Terraform outputs)
4. Create HTTP load balancers for both regions

## Delete

```bash
./xC-use-cases/vk8s/bin/delete.sh
```

This script will:
1. Delete the HTTP load balancers
2. Delete the origin pools
3. Delete the workload
4. Destroy the vk8s cluster via Terraform
5. Clean up generated payload files

## Configuration

All credentials and tenant settings are loaded from `setup-init/config.yaml` via the shared config loader. No passwords are hardcoded in the scripts.

### Files

| Path | Description |
|------|-------------|
| `bin/setup.sh` | Automated deployment script |
| `bin/delete.sh` | Automated teardown script |
| `etc/__template_workload.json` | Workload template for echo-aws |
| `etc/__template_origin-vk8s-eu-central.json` | Origin pool template (eu-central) |
| `etc/__template_origin-vk8s-eu-west.json` | Origin pool template (eu-west) |
| `etc/__template_lb-vk8s-eu-central.json` | Load balancer template (eu-central) |
| `etc/__template_lb-vk8s-eu-west.json` | Load balancer template (eu-west) |
| `terraform/` | Terraform config for vk8s cluster creation |
