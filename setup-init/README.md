# Setup Initialization

This directory contains all scripts and configuration for initializing the xC MCN Demo Lab.

> **ATTENTION:** The full HTML Lab Guide lives at **[docs/lab-guide/index.html](../docs/lab-guide/index.html)**.
> It includes Quick Start, Detailed Setup, and all Use Case steps in one place.

## Quick Start

```bash
# 1. Copy and configure
cp ./template/config.yaml ./config.yaml
# Edit config.yaml with your credentials

# 2. Place xC P12 certificate
cp /path/to/your-cert.p12 ./.xC/

# 3. Initialize (generates CA, sets up AWS, deploys Terraform)
./bin/initialize.sh init
```

## Available Commands

| Command | Description |
|---------|-------------|
| `./bin/initialize.sh init` | Full initialization: CA generation, AWS credentials, xC cert conversion, Terraform deployment |
| `./bin/initialize.sh update-creds` | Update AWS credentials only (after STS token rotation) |
| `./bin/initialize.sh generate-ca` | Generate Certificate Authority only |
| `./bin/delete.sh` | Destroy all Terraform-managed infrastructure |

## Directory Structure

```
setup-init/
├── bin/
│   ├── initialize.sh        # Main initialization wrapper
│   └── delete.sh            # Teardown script
├── src/
│   └── setup_init/          # Python package
│       ├── cli.py           # CLI orchestration
│       ├── config.py        # Configuration loading
│       ├── aws.py           # AWS credential management
│       ├── ca.py            # CA generation
│       ├── terraform.py     # Terraform wrapper
│       ├── xc.py            # xC certificate handling
│       └── network.py       # Network utilities
├── lib/
│   └── common-config-loader.sh  # Shared config loader for shell scripts
├── template/
│   └── config.yaml          # Configuration template
├── .xC/                     # xC API certificates (gitignored)
├── .cert/                   # Generated certificates (gitignored)
│   ├── ca/                  #   CA key + cert
│   └── domains/             #   Server + client certs
├── .ssh/                    # SSH keys and helpers
└── config.yaml              # Your configuration (gitignored)
```

---

## Parameter Guide

<table style="width:100%">
<thead>
<tr>
<th style="width:20%">Parameter</th>
<th style="width:50%">Description</th>
<th style="width:15%">Mandatory</th>
<th style="width:15%">Default</th>
</tr>
</thead>
<tbody>

<tr><td colspan="4"><strong>AWS Configuration</strong></td></tr>

<tr>
<td><code>aws.auth_profile</code></td>
<td>Name of the AWS credential profile in <code>~/.aws/credentials</code></td>
<td>Yes</td>
<td><code>xc-mcn-lab</code></td>
</tr>
<tr>
<td><code>aws.aws_access_key_id</code></td>
<td>AWS Access Key ID for API authentication</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>aws.aws_secret_access_key</code></td>
<td>AWS Secret Access Key for API authentication</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>aws.aws_session_token</code></td>
<td>AWS Session Token (required if <code>tmp_aws_cred: true</code>)</td>
<td>If STS</td>
<td>—</td>
</tr>
<tr>
<td><code>aws.region_site_1</code></td>
<td>First AWS region for deployment</td>
<td>Yes</td>
<td><code>eu-central-1</code></td>
</tr>
<tr>
<td><code>aws.region_site_2</code></td>
<td>Second AWS region for deployment</td>
<td>Yes</td>
<td><code>eu-west-1</code></td>
</tr>
<tr>
<td><code>aws.tmp_aws_cred</code></td>
<td>Set to <code>true</code> for STS/temporary credentials, <code>false</code> for static keys</td>
<td>Yes</td>
<td><code>true</code></td>
</tr>

<tr><td colspan="4"><strong>Student Configuration</strong></td></tr>

<tr>
<td><code>student.name</code></td>
<td>Unique identifier for this lab instance. Used in resource naming. DNS-safe: lowercase <code>[a-z0-9-]</code>, 1-16 chars, start/end alphanumeric.</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>student.email</code></td>
<td>Contact email for resource tagging</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>student.ip-address</code></td>
<td>Your public IP (auto-populated during initialization)</td>
<td>Auto</td>
<td>Auto-detected</td>
</tr>

<tr><td colspan="4"><strong>F5 BIG-IP Configuration</strong></td></tr>

<tr>
<td><code>f5.f5_password</code></td>
<td>Password for BIG-IP admin user</td>
<td>Yes</td>
<td><code>DefaultLabPwd!2026</code></td>
</tr>

<tr><td colspan="4"><strong>F5 Distributed Cloud (xC) Configuration</strong></td></tr>

<tr>
<td><code>xC.p12_auth</code></td>
<td>Path to your xC API certificate (P12 format), relative to <code>setup-init/</code></td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>xC.p_12_pwd</code></td>
<td>Password to decrypt the P12 certificate</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>xC.tenant</code></td>
<td>Your xC tenant name (full name)</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>xC.tenant_shrt</code></td>
<td>Your xC tenant short name</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>xC.tenant_api</code></td>
<td>xC API endpoint URL</td>
<td>Yes</td>
<td>—</td>
</tr>
<tr>
<td><code>xC.namespace</code></td>
<td>xC namespace for resources</td>
<td>Yes</td>
<td>—</td>
</tr>

<tr><td colspan="4"><strong>Certificate Paths</strong></td></tr>

<tr>
<td><code>cert.ca_dir</code></td>
<td>Directory for CA key + cert (relative to <code>setup-init/</code>)</td>
<td>No</td>
<td><code>.cert/ca</code></td>
</tr>
<tr>
<td><code>cert.cert_dir</code></td>
<td>Directory for server/client certificates (relative to <code>setup-init/</code>)</td>
<td>No</td>
<td><code>.cert/domains</code></td>
</tr>
<tr>
<td><code>cert.ca_key</code></td>
<td>Path to CA private key (auto-populated after generation)</td>
<td>Auto</td>
<td>—</td>
</tr>
<tr>
<td><code>cert.ca_cert</code></td>
<td>Path to CA certificate (auto-populated after generation)</td>
<td>Auto</td>
<td>—</td>
</tr>

<tr><td colspan="4"><em>CA OpenSSL settings (key_size, validity_days, DN) are configured in <code>tools/s-certificate/config/config.yaml</code> under the <code>certificate.ca:</code> section.</em></td></tr>

</tbody>
</table>

---

## Certificate Authority Integration

During initialization, a Certificate Authority (CA) is automatically generated in `setup-init/.cert/ca/`. This CA is used to sign server and client certificates via the `s-certificate` tool.

All certificate artifacts are stored under `setup-init/.cert/`:

```
setup-init/.cert/
├── ca/                     # CA key + cert (auto-generated)
│   ├── ca.key
│   └── ca.cer
└── domains/                # Server + client certs (generated per domain)
    ├── myapp.example.com.p12
    ├── myapp.example.com.client.key
    └── myapp.example.com.client.cert
```

The `s-certificate` tool auto-detects the project config when run from within the repository:

```bash
cd tools/s-certificate
./bin/run-s-certificate.sh myapp.example.com
```

CA paths and the output directory are read from `setup-init/config.yaml` — no need to configure them in the tool's own config.
