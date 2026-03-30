# Configuration Parameters

Complete reference for all parameters in `setup-init/config.yaml`.

Copy the template before first use:

```bash
cp setup-init/template/config.yaml setup-init/config.yaml
```

Only **5 fields** need to be filled in manually. Everything else is auto-detected, auto-derived, or has sensible defaults.

---

## student

| Parameter | Required | Auto | Description |
|:----------|:--------:|:----:|:------------|
| `name` | **Yes** | — | Your unique lab ID. Used in DNS names, certificate names, xC object names, SSH key paths, and Route53 records. **Choose carefully — changing it later requires a full teardown and redeploy.** Rules: lowercase letters, digits, hyphens only (`[a-z0-9-]`), max 16 characters, must start and end with a letter or digit. |
| `email` | **Yes** | — | Contact email. Used for resource tagging (`owner` tag on AWS resources). |
| `ip-address` | No | Yes | Your public IP (CIDR format). Auto-detected during initialization. Used in AWS security groups to restrict access to lab resources. |

---

## xC

| Parameter | Required | Auto | Description |
|:----------|:--------:|:----:|:------------|
| `tenant` | **Yes** | — | Full xC tenant name (e.g. `f5-emea-ent-bceuutam`). Found in xC Console under Administration. |
| `namespace` | **Yes** | — | xC namespace for all lab objects (e.g. `m-petersen`). |
| `p_12_pwd` | **Yes** | — | Password for the .p12 certificate. |
| `p12_auth` | No | Yes | Path to the xC API certificate (.p12 file). **Auto-detected** from the `setup-init/.xC/` directory: if a `.p12` file matching the tenant name exists, it is used automatically. If multiple files match, the newest is selected. Set manually to override. |
| `tenant_shrt` | No | Yes | Short tenant name. Auto-derived from `tenant` by removing the last segment (e.g. `volt-field-vhptnhxg` → `volt-field`). |
| `tenant_api` | No | Yes | xC API endpoint. Auto-derived from `tenant_shrt` as `https://{tenant_shrt}.console.ves.volterra.io/api`. |
| `tenant_anycast_ip` | No | Yes | Anycast IP for RE load balancers. Auto-fetched from xC API during initialization. Set manually to override with a secondary IP — you will be asked during init whether to keep your value or use the API result. |

---

## aws

| Parameter | Required | Env Var Override | Description |
|:----------|:--------:|:-----------------|:------------|
| `aws_access_key_id` | Yes * | `AWS_ACCESS_KEY_ID` | AWS access key. Set in the file **or** as an environment variable (env var takes priority). |
| `aws_secret_access_key` | Yes * | `AWS_SECRET_ACCESS_KEY` | AWS secret key. Same override logic as above. |
| `aws_session_token` | If STS | `AWS_SESSION_TOKEN` | Required for STS/temporary credentials. STS vs static is **auto-detected** based on whether a session token is present. |
| `auth_profile` | No | — | AWS CLI profile name written to `~/.aws/credentials`. Default: `xc-mcn-lab`. |
| `region_site_1` | No | — | AWS region for the first lab site. Default: `eu-central-1`. |
| `region_site_2` | No | — | AWS region for the second lab site. Default: `eu-west-1`. |

\* Can be left empty in the file if the corresponding environment variable is set.

---

## f5

| Parameter | Required | Default | Description |
|:----------|:--------:|:--------|:------------|
| `f5_password` | No | `DefaultLabPwd!2026` | BIG-IP admin password. Change this to a secure value before deploying in shared environments. |

---

## cert

| Parameter | Required | Auto | Description |
|:----------|:--------:|:----:|:------------|
| `ca_dir` | No | — | Directory for the CA key and certificate. Default: `.cert/ca`. |
| `cert_dir` | No | — | Directory for server and client certificates. Default: `.cert/domains`. |
| `ca_key` | No | Yes | Path to the CA private key. Auto-populated after CA generation. |
| `ca_cert` | No | Yes | Path to the CA certificate. Auto-populated after CA generation. |
