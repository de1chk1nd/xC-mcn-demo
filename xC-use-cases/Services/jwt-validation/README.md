# JWT Validation

Create an HTTPS load balancer with **JWT validation** in blocking mode. Requests without a valid Bearer token are rejected. The lab CA private key signs the JWTs (RS256), and the corresponding public key is provided as inline JWKS to the load balancer.

<!-- TODO: architecture diagram placeholder -->

> **Lab Guide:** [Open in Lab Guide](../../../docs/lab-guide/index.html#svc-jwt)

## Technical Overview

The setup script generates JWTs signed by the lab CA, extracts the public key as JWKS, creates a server certificate, and deploys an HTTP load balancer with JWT validation configured in blocking mode.

### Key Concepts

- **RS256 signing**: JWTs are signed with the lab CA private key (`setup-init/.cert/ca/ca.key`)
- **JWKS**: The CA's RSA public key is extracted as a JSON Web Key Set and embedded inline in the LB config
- **Blocking mode**: Requests without a valid JWT are rejected (not just logged)
- **Claims validation**: Issuer (`iss`) and audience (`aud`) are validated against expected values
- **Two test tokens**: One valid (correct claims), one invalid (wrong issuer)

### JWT Claims

| Claim | Valid Token | Invalid Token |
|-------|------------|---------------|
| `iss` | `https://lab.{student}.xc-mcn-lab.aws` | `https://evil.attacker.com` |
| `aud` | `https://jwt.{student}.xc-mcn-lab.aws` | `https://jwt.{student}.xc-mcn-lab.aws` |
| `sub` | `{student}@xc-mcn-lab` | `attacker@evil.com` |
| `exp` | +1 year | +1 year |

### API Endpoints

| Method | Endpoint | Object |
|--------|----------|--------|
| POST | `/api/config/namespaces/{ns}/certificates` | `tls-{student}-jwt` |
| POST | `/api/config/namespaces/{ns}/http_loadbalancers` | `lb-jwt` |
| DELETE | (reverse order) | All of the above |

### Script Flow — setup.sh

1. Load config via `common-config-loader.sh`
2. Ensure `s-certificate` tool config exists
3. Generate server certificate via `s-certificate --no-p12 --keep-pem` → upload to xC
4. Generate JWT tokens + JWKS via `generate-tokens.py` (uses lab CA private key)
5. Inline JWKS into LB template, render via `envsubst`
6. Create HTTP load balancer with `jwt_validation` block (blocking mode, RS256, claims check)

### Script Flow — delete.sh

1. Delete HTTP load balancer
2. Delete server certificate from xC
3. Remove generated tokens, JWKS, payloads, local PEM files, and s-certificate config

## Files

| Path | Type | Description |
|------|------|-------------|
| `bin/setup.sh` | Permanent | Automated deployment script |
| `bin/delete.sh` | Permanent | Automated teardown script |
| `bin/generate-tokens.py` | Permanent | JWT + JWKS generator (RS256, lab CA key) |
| `etc/__template_lb-jwt.json` | Permanent | HTTP LB template with JWT validation config |
| `etc/tokens/valid.jwt` | Temporary | Valid JWT (correct issuer + audience) |
| `etc/tokens/invalid.jwt` | Temporary | Invalid JWT (wrong issuer) |
| `etc/tokens/jwks.json` | Temporary | JWKS with CA public key |
| `payload_final_*.json` | Temporary | Generated payloads (gitignored) |
| `setup-init/.cert/domains/jwt.*.{cert,key}` | Temporary | Server PEM files (gitignored) |
