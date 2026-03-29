# Configuration Parameters

Complete reference for all parameters in `setup-init/config.yaml`.

Copy the template before first use:

```bash
cp setup-init/template/config.yaml setup-init/config.yaml
```

---

## aws

| Parameter | Required | Default | Env Var Override | Description |
|:----------|:--------:|:--------|:-----------------|:------------|
| `aws_access_key_id` | Yes | — | `AWS_ACCESS_KEY_ID` | AWS access key. Can be set in the file or as an environment variable (env var takes priority). |
| `aws_secret_access_key` | Yes | — | `AWS_SECRET_ACCESS_KEY` | AWS secret key. Same override logic as above. |
| `aws_session_token` | If STS | — | `AWS_SESSION_TOKEN` | Required when `tmp_aws_cred` is `true` (STS/temporary credentials). Leave empty for static IAM keys. |
| `tmp_aws_cred` | No | `true` | — | Set `true` for STS temporary credentials, `false` for static IAM keys. |
| `auth_profile` | No | `xc-mcn-lab` | — | AWS CLI profile name written to `~/.aws/credentials`. Usually no change needed. |
| `region_site_1` | No | `eu-central-1` | — | AWS region for the first lab site. |
| `region_site_2` | No | `eu-west-1` | — | AWS region for the second lab site. |

---

## student

| Parameter | Required | Default | Auto | Description |
|:----------|:--------:|:--------|:----:|:------------|
| `name` | Yes | — | — | Your unique lab ID. Used in DNS names, certificate names, xC object names, SSH key paths, and Route53 records. **Choose carefully — changing it later requires a full teardown and redeploy.** Rules: lowercase letters, digits, hyphens only (`[a-z0-9-]`), max 16 characters, must start and end with a letter or digit. |
| `email` | Yes | — | — | Contact email. Used for resource tagging (`owner` tag on AWS resources). |
| `ip-address` | No | — | Yes | Your public IP (CIDR format). Auto-detected during initialization. Used in AWS security groups to restrict access to lab resources. |

---

## xC

| Parameter | Required | Default | Auto | Description |
|:----------|:--------:|:--------|:----:|:------------|
| `p12_auth` | Yes | — | — | Path to the xC API certificate (.p12 file), relative to `setup-init/`. Example: `.xC/my-cert.p12` |
| `p_12_pwd` | Yes | — | — | Password for the .p12 certificate. |
| `tenant` | Yes | — | — | Full xC tenant name (e.g. `f5-emea-ent-bceuutam`). Found in xC Console under Administration. |
| `namespace` | Yes | — | — | xC namespace for all lab objects (e.g. `m-petersen`). |
| `tenant_shrt` | No | — | Yes | Short tenant name. Auto-derived from `tenant` by removing the last segment (e.g. `f5-emea-ent-bceuutam` → `f5-emea-ent`). |
| `tenant_api` | No | — | Yes | xC API endpoint. Auto-derived from `tenant` as `https://{tenant}.console.ves.volterra.io/api`. |
| `tenant_anycast_ip` | No | — | Yes | Anycast IP for RE load balancers. Auto-fetched from xC API during initialization. If you set a value manually (e.g. a secondary IP), you will be asked during init whether to keep it or use the API value. Find it in: xC Console → DNS Management → delegated domain IP. |

---

## f5

| Parameter | Required | Default | Description |
|:----------|:--------:|:--------|:------------|
| `f5_password` | No | `DefaultLabPwd!2026` | BIG-IP admin password. Change this to a secure value before deploying in shared environments. |

---

## cert

| Parameter | Required | Default | Auto | Description |
|:----------|:--------:|:--------|:----:|:------------|
| `ca_dir` | No | `.cert/ca` | — | Directory for the CA key and certificate (relative to `setup-init/`). |
| `cert_dir` | No | `.cert/domains` | — | Directory for server and client certificates (relative to `setup-init/`). |
| `ca_key` | No | — | Yes | Path to the CA private key. Auto-populated after CA generation. |
| `ca_cert` | No | — | Yes | Path to the CA certificate. Auto-populated after CA generation. |
