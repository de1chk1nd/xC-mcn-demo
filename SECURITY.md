# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please send an email or contact the maintainer directly through GitHub.

## Scope

This project is a demo/lab environment for F5 Distributed Cloud (xC) multi-cloud networking use cases. It is **not intended for production use**.

## Credentials & Secrets

- Never commit real credentials, API keys, or certificates to this repository
- The file `setup-init/config.yaml` is excluded from version control via `.gitignore`
- Use `setup-init/template/config.yaml` as a reference for required configuration values
- All secrets are loaded at runtime from the local configuration file

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |
| Older   | No        |
