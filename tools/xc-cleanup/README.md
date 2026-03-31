# xc-cleanup

Read-only tool to check whether all xC objects created by lab use-case scripts have been properly deleted.

> **Usage:** `make xc-cleanup` or `./tools/xc-cleanup/bin/check-objects.sh`

## What it checks

Performs a GET request for each of the 44 known xC objects across 8 resource types:

| Type | Count |
|------|-------|
| `http_loadbalancers` | 17 |
| `certificates` | 16 |
| `origin_pools` | 5 |
| `discoverys` | 2 |
| `virtual_k8ss` | 1 |
| `workloads` | 1 |
| `trusted_ca_lists` | 1 |
| `service_policys` | 1 |

## Output

```
══════════════════════════════════════════════════════════════════
  xC MCN Demo Lab — Object Cleanup Check
  Tenant:    volt-field
  Namespace: m-petersen
  Student:   de1chk1nd
══════════════════════════════════════════════════════════════════

  Object Name                     Type                Use Case
  ──────────────────────────────────────────────────────────────
  ✓ clean    lb-echo-public         http_loadbalancers  RE-only
  ✗ EXISTS   lb-echo-hybrid         http_loadbalancers  RE-to-CE
  ...

  ──────────────────────────────────────────────────────────────
  ✗ Exists: 2   ✓ Clean: 42   ? Errors: 0

  Objects still present — run the corresponding delete script:
    make uc-<name>-delete  or  make svc-<name>-delete
```

## Important

- **Read-only** — does not modify or delete anything
- Exit code `0` = all clean, exit code `1` = objects found
- Requires `setup-init/.xC/xc-curl.crt.pem` (run `initialize.sh init` first)
