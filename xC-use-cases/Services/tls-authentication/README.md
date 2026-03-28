# TLS Authentication (mTLS)

Create an HTTPS load balancer with **mutual TLS (mTLS)** authentication. Clients must present a valid client certificate signed by the lab CA. The load balancer extracts certificate fields and injects them as HTTP headers, making client identity available to the backend application.

<!-- TODO: add architecture diagram -->

> **Lab Guide:** [Open in Lab Guide](../../../docs/lab-guide/index.html#svc-tls-auth)

## Technical Overview

The setup script generates a CA-signed server certificate for the LB, creates client certificates for two test users, and configures the HTTP load balancer with mTLS enabled. The CA certificate is embedded in the LB config as `trusted_ca_url` so the CE/RE can validate client certs.

### Key Concepts

- **Server cert**: Used by the LB for TLS termination (same as other use cases)
- **Client certs**: Signed by the same lab CA, one per user (email as CN + SAN)
- **mTLS on LB**: Replaces `no_mtls` with `mtls` block containing `trusted_ca_url` (CA cert) and `client_certificate_headers` (header injection)
- **Header injection**: The LB extracts cert fields (issuer, subject, serial, fingerprint, validity) and adds them as `x-client-cert-*` headers to the upstream request

### XFCC Header Elements Injected

The LB injects an `x-forwarded-client-cert` (XFCC) header with these elements:

| Element | Content |
|---------|---------|
| `Cert` | URL-encoded client certificate |
| `Chain` | URL-encoded certificate chain |
| `Subject` | Client cert subject DN (e.g. `CN=alice@mordor.de`) |
| `URI` | SAN URI if present |
| `DNS` | SAN DNS if present |

### API Endpoints

| Method | Endpoint | Object |
|--------|----------|--------|
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-mtls` |
| POST | `/api/config/namespaces/{ns}/trusted_ca_lists` | `ca-{student}-mtls` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-mtls` |
| POST | `/api/config/namespaces/{ns}/service_policys` | `sp-{student}-mtls-cert-check` |
| DELETE | (reverse order) | All of the above |

### Script Flow — setup.sh

1. Load config via `common-config-loader.sh`
2. Ensure `s-certificate` tool config exists
3. Generate server certificate via `s-certificate --no-p12 --keep-pem` → upload to xC
4. Generate client certificates for `alice@mordor.de` and `bob@shire.de` via `openssl` (CA-signed, `clientAuth` EKU, email as SAN)
5. Base64-encode CA cert, create `trusted_ca_list` object on xC (lab CA for client cert validation)
6. Render all templates via `envsubst` (LB, trusted CA, service policy)
7. Create HTTP load balancer with mTLS enabled
8. Create service policy (matches XFCC header to allow only `@mordor.de` clients)

**Note:** The service policy must be manually assigned to the load balancer in the xC Console.

### Script Flow — delete.sh

1. Delete service policy
2. Delete HTTP load balancer
3. Delete server certificate from xC
4. Delete trusted CA list from xC
5. Remove client certs, generated payloads, local PEM files, and s-certificate config

### Client Certificate Generation Details

Client certs are generated directly via `openssl` (not the s-certificate tool) because each user needs a unique email/CN:

```
Subject: /C=DE/ST=Lab/L=Lab/O=xC-MCN-Lab/OU={student}/CN={email}/emailAddress={email}
EKU:     clientAuth
SAN:     email:{email}
Signed:  Lab CA (setup-init/.cert/ca/)
```

## Files

| Path | Type | Description |
|------|------|-------------|
| `bin/setup.sh` | Permanent | Automated deployment script |
| `bin/delete.sh` | Permanent | Automated teardown script |
| `etc/__template_trusted-ca.json` | Permanent | Trusted CA list template (lab CA for mTLS) |
| `etc/__template_lb-mtls.json` | Permanent | HTTP LB template with mTLS config |
| `etc/__template_service-policy.json` | Permanent | Service policy: deny non-@mordor.de clients |
| `etc/client-certs/` | Temporary | Generated client cert/key pairs (gitignored) |
| `payload_final_*.json` | Temporary | Generated payloads (gitignored) |
| `setup-init/.cert/domains/mtls.*.{cert,key}` | Temporary | Server PEM files (gitignored) |
