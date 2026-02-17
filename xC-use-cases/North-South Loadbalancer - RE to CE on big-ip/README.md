# North-South Loadbalancer - RE to CE via local BigIP

Create HTTP load balancers with ingress via **Regional Edge (RE)** and egress via **Customer Edge (CE)** on AWS, forwarding traffic to a local **BIG-IP** appliance (without Service Discovery). One load balancer per region, each pointing to the BIG-IP origin pool in its respective region. A default **Web Application Firewall** policy is attached to each load balancer.

![Use Case - RE to CE w bigip](../../docs/images/use-cases/RE-to-CE%20w%20bigip.png)

## Prerequisites

- `setup-init/config.yaml` configured with valid XC credentials
- PEM certificate generated (run `python3 setup-init/initialize_infrastructure.py`)
- Infrastructure deployed (`terraform apply` in `infrastructure/`)
- Origin pools `origin-bigip-echossl-aws-eu-central-1` and `origin-bigip-echossl-aws-eu-west-1` must exist (created by infrastructure Terraform)
- BIG-IP appliances online and AS3 deployment completed
- `yq`, `envsubst`, and `curl` installed

## Deploy

```bash
"./xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/setup.sh"
```

This script will:
1. Generate load balancer payloads from templates
2. Create HTTP load balancer `lb-bigip-echo-eu-central` via XC API
3. Create HTTP load balancer `lb-bigip-echo-eu-west` via XC API

## Test / Verify

### BIG-IP Access

| Device | Username | Password (lab-default) |
|:---|:---|:---|
| BIG-IP EU-Central | admin | DefaultLabPwd!2026 |
| BIG-IP EU-West | admin | DefaultLabPwd!2026 |

> Before you can access the BIG-IP management UI, add local `/etc/hosts` entries (see Post Install in the main README).

### Verify custom header

After deployment, access the load balancer FQDN and check for the **custom-header** injected by the BIG-IP:

![Header JSON](../../docs/images/use-cases/re-to-ce-bigip/00-header-json.png)

### Optional: BIG-IP APM local authentication

Add an APM access policy with local user authentication on the eu-central BIG-IP:

1. **Create local user database** (`/Common/local-user-db`):

   ![Local User DB](../../docs/images/use-cases/re-to-ce-bigip/01-bigip-local-user-db.png)

2. **Create a user**: username `alice`, password of your choice, instance `/Common/local-user-db`

3. **Create Access Profile** (`local-auth`, type: All, language: English):

   ![Access Profile](../../docs/images/use-cases/re-to-ce-bigip/02-access-profile.png)

4. **Edit profile**: Start → Login Page → Authentication (LocalDB Auth, instance `/Common/local-auth`) → Allow → **Apply Access Policy**

5. **Assign policy**: switch to partition `xcmcnlab`, assign `local-auth` to virtual server `echo443tlspass`

6. Access the FQDN again -- an authentication prompt should appear:

   ![Auth Screen](../../docs/images/use-cases/re-to-ce-bigip/003-auth-screen.png)

## Delete

```bash
"./xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/delete.sh"
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
| `etc/__template_lb-bigip-echo-eu-central.json` | LB template -- eu-central |
| `etc/__template_lb-bigip-echo-eu-west.json` | LB template -- eu-west |
