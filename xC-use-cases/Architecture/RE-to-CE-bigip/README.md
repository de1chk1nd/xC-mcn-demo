# North-South: RE to CE via BIG-IP

Create HTTP load balancers with ingress via **Regional Edge (RE)** and egress via **Customer Edge (CE)** on AWS, forwarding traffic to a local **BIG-IP** appliance. One load balancer per region. A BIG-IP iRule injects a custom header, demonstrating F5 "better together" integration. A default Web Application Firewall policy is attached.

![Architecture](../../../docs/images/use-cases/RE-to-CE%20w%20bigip.png)

> **Lab Guide:** [Open in Lab Guide](../../../docs/lab-guide/index.html#ns-re-ce-bigip)

## Technical Overview

Pure API automation — generates two CA-signed server certificates, uploads them to xC, then creates two HTTP load balancers. Origin pools reference BIG-IP virtual servers provisioned by the base infrastructure (AS3).

### API Endpoints

| Method | Endpoint | Object |
|--------|----------|--------|
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-bigip-echo-eu-central` |
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-bigip-echo-eu-west` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-bigip-echo-eu-central` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-bigip-echo-eu-west` |
| DELETE | (reverse order) | All of the above |

### Script Flow — setup.sh

1. Load config via `common-config-loader.sh`
2. Ensure `s-certificate` tool config exists
3. Loop over 2 domains: generate cert → base64 encode → upload to xC
4. Render 2 LB templates via `envsubst`
5. Create 2 HTTP load balancers

### Script Flow — delete.sh

1. Delete 2 HTTP load balancers
2. Delete 2 certificates from xC
3. Remove local PEM files, generated payloads, and s-certificate config

## Files

| Path | Type | Description |
|------|------|-------------|
| `bin/setup.sh` | Permanent | Automated deployment script |
| `bin/delete.sh` | Permanent | Automated teardown script |
| `etc/__template_lb-bigip-echo-eu-central.json` | Permanent | LB template — eu-central |
| `etc/__template_lb-bigip-echo-eu-west.json` | Permanent | LB template — eu-west |
| `payload_final_*.json` | Temporary | Generated payloads (gitignored) |
| `setup-init/.cert/domains/bigip-echo-eu-*.{cert,key}` | Temporary | Generated PEM files (gitignored) |
