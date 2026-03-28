# North-South: RE to CE

Create HTTP load balancers with ingress via **Regional Edge (RE)** and egress via **Customer Edge (CE)** on AWS. Three load balancers are deployed: a combined LB routing to both regions, and one dedicated LB per region. A default Web Application Firewall policy is attached.

![Architecture](../../../docs/images/use-cases/RE-to-CE.png)

> **Lab Guide:** [Open in Lab Guide](../../../docs/lab-guide/index.html#ns-re-ce)

## Technical Overview

Pure API automation — generates three CA-signed server certificates, uploads them to xC, then creates three HTTP load balancers. No origin pools are created by this script; they reference pre-existing origin pools from the base infrastructure.

### API Endpoints

| Method | Endpoint | Object |
|--------|----------|--------|
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-echo-hybrid` |
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-echo-hybrid-central` |
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-echo-hybrid-west` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-echo-hybrid` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-echo-hybrid-central` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-echo-hybrid-west` |
| DELETE | (reverse order) | All of the above |

### Script Flow — setup.sh

1. Load config via `common-config-loader.sh`
2. Ensure `s-certificate` tool config exists
3. Loop over 3 domains: generate cert → base64 encode → upload to xC
4. Render 3 LB templates via `envsubst`
5. Create 3 HTTP load balancers

### Script Flow — delete.sh

1. Delete 3 HTTP load balancers
2. Delete 3 certificates from xC
3. Remove local PEM files, generated payloads, and s-certificate config

## Files

| Path | Type | Description |
|------|------|-------------|
| `bin/setup.sh` | Permanent | Automated deployment script |
| `bin/delete.sh` | Permanent | Automated teardown script |
| `etc/__template_lb-echo-ssl.json` | Permanent | LB template — both regions |
| `etc/__template_lb-echo-ssl-central.json` | Permanent | LB template — eu-central only |
| `etc/__template_lb-echo-ssl-west.json` | Permanent | LB template — eu-west only |
| `payload_final_*.json` | Temporary | Generated payloads (gitignored) |
| `setup-init/.cert/domains/echo-hybrid*.{cert,key}` | Temporary | Generated PEM files (gitignored) |
