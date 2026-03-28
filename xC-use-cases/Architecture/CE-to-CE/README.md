# East-West: CE to CE

Create internal HTTPS load balancers for **cross-region east-west traffic** between Customer Edge sites. Each region gets an LB that routes to the opposite region's origin pool. No VPC peering or Transit Gateway required — connectivity is provided entirely by the xC fabric. A default Web Application Firewall policy is attached.

![Architecture](../../../docs/images/use-cases/CE-to-CE.png)

> **Lab Guide:** [Open in Lab Guide](../../../docs/lab-guide/index.html#ew-ce)

## Technical Overview

Pure API automation — generates one CA-signed server certificate (shared FQDN across both LBs), uploads it to xC, then creates two HTTP load balancers with `advertise_custom` on CE virtual sites (`SITE_NETWORK_INSIDE`).

Both LBs use the same FQDN `remote-web.<domain>`, but each is advertised only on the CE in its own region. When an Ubuntu server in eu-central resolves the name, it reaches the local CE, which routes through the xC fabric to the origin pool in eu-west — and vice versa.

### API Endpoints

| Method | Endpoint | Object |
|--------|----------|--------|
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-remote-web` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-api-int-central` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-api-int-west` |
| DELETE | (reverse order) | All of the above |

### Script Flow — setup.sh

1. Load config via `common-config-loader.sh`
2. Ensure `s-certificate` tool config exists
3. Generate 1 server certificate (`remote-web.<domain>`) → base64 encode → upload to xC
4. Render 2 LB templates via `envsubst`
5. Create 2 HTTP load balancers (each advertised on its region's CE, routing to the opposite region)

### Script Flow — delete.sh

1. Delete 2 HTTP load balancers
2. Delete 1 certificate from xC
3. Remove local PEM files, generated payloads, and s-certificate config

## Files

| Path | Type | Description |
|------|------|-------------|
| `bin/setup.sh` | Permanent | Automated deployment script |
| `bin/delete.sh` | Permanent | Automated teardown script |
| `etc/__template_ew_loadbalancing-eu-central.json` | Permanent | LB template — advertised on eu-central, routes to eu-west |
| `etc/__template_ew_loadbalancing-eu-west.json` | Permanent | LB template — advertised on eu-west, routes to eu-central |
| `payload_final_*.json` | Temporary | Generated payloads (gitignored) |
| `setup-init/.cert/domains/remote-web.*.{cert,key}` | Temporary | Generated PEM files (gitignored) |
