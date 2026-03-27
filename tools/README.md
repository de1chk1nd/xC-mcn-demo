# Tools

Standalone utilities supporting the xC MCN demo lab environment.
Each tool lives in its own subdirectory with independent dependencies and documentation.

## Available Tools

| Tool | Purpose | Docs |
|------|---------|------|
| [s-certificate](s-certificate/) | Generate CA-signed server certificates, optional XC upload and mTLS client certs | [README](s-certificate/README.md) |

## Conventions

Every tool follows a consistent layout:

```
tools/<tool-name>/
├── bin/              # Shell entry points
├── src/              # Source code
├── config/           # Configuration (*.example files tracked, real configs gitignored)
├── docs/             # Tool-specific documentation
├── README.md         # Purpose, setup, usage
└── requirements.txt  # Dependencies (Python tools)
```
