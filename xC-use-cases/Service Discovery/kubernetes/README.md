# Service Discovery - Kubernetes

Create Kubernetes service discovery objects for minikube clusters running on CE sites, then build origin pools and HTTP load balancers that route to discovered K8s services. The setup script SSHs into each Ubuntu server to fetch the kubeconfig and deploy the echo application, then registers everything with the XC API.

![Use Case - Service Discovery k8s](../../../docs/images/use-cases/SD-k8s.png)

## Prerequisites

- `setup-init/config.yaml` configured with valid XC credentials
- PEM certificate generated (run `python3 setup-init/initialize_infrastructure.py`)
- Infrastructure deployed (`terraform apply` in `infrastructure/`)
- Local `/etc/hosts` entries configured (for SSH access to Ubuntu servers)
- Minikube running on both Ubuntu servers
- `yq`, `envsubst`, `curl`, `base64`, and `ssh` installed

## Further Reading

| Resource | Notes |
|:---|:---|
| [K8s Architecture Options](https://community.f5.com/kb/technicalarticles/kubernetes-architecture-options-with-f5-distributed-cloud-services/306550) | General k8s options -- focus on **Secure k8s Gateway** |
| [SD kubeconfig](https://community.f5.com/kb/technicalarticles/service-discovery-and-authentication-options-for-kubernetes-providers-eks-aks-gc/297576) | How to create kubeconfig for cloud providers |
| [SD k8s RBAC](https://community.f5.com/kb/technicalarticles/using-a-kubernetes-serviceaccount-for-service-discovery-with-f5-distributed-clou/300225) | Create kubeconfig with RBAC |

## Deploy

```bash
"./xC-use-cases/Service Discovery/kubernetes/bin/setup.sh"
```

This script will:
1. SSH to each Ubuntu server and fetch the minikube kubeconfig
2. Deploy the echo application to both minikube clusters
3. Base64-encode kubeconfigs and generate all payloads from templates
4. Create K8s service discovery objects for eu-central and eu-west
5. Create origin pools `origin-k8s-central` and `origin-k8s-west`
6. Create HTTP load balancers `lb-k8s-central`, `lb-k8s-west`, and `lb-k8s` (both regions)

## Delete

```bash
"./xC-use-cases/Service Discovery/kubernetes/bin/delete.sh"
```

This script will:
1. Delete all three HTTP load balancers
2. Delete both origin pools
3. Delete both service discovery objects
4. Clean up generated payload and kubeconfig files

## Configuration

All credentials and tenant settings are loaded from `setup-init/config.yaml` via the shared config loader. No passwords are hardcoded in the scripts.

### Files

| Path | Description |
|------|-------------|
| `bin/setup.sh` | Automated deployment script |
| `bin/delete.sh` | Automated teardown script |
| `etc/__template_sd_eu-central.json` | Service discovery template (eu-central) |
| `etc/__template_sd_eu-west.json` | Service discovery template (eu-west) |
| `etc/__template_origin_eu-central.json` | Origin pool template (eu-central) |
| `etc/__template_origin_eu-west.json` | Origin pool template (eu-west) |
| `etc/__template_lb-k8s.json` | LB template -- both regions |
| `etc/__template_lb-k8s-central.json` | LB template -- eu-central only |
| `etc/__template_lb-k8s-west.json` | LB template -- eu-west only |
