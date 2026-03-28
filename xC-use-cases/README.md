# xC Use Cases

A collection of F5 Distributed Cloud (xC) use cases for the xC-mcn-demo lab. Each use case has automated `setup.sh` and `delete.sh` scripts.

> **Lab Guide:** Full interactive lab at [docs/lab-guide/index.html](../docs/lab-guide/index.html)

## Production Use Cases

| Use Case | Direction | Ingress | Egress | WAF | [Tech Docs](.) | [Lab Guide](../docs/lab-guide/index.html) |
|:---|:---|:---|:---|:---|:---|:---|
| N-S RE only | North-South | RE | Internet | Yes | [README](Architecture/RE-only/README.md) | [Lab](../docs/lab-guide/index.html#ns-re) |
| N-S RE to CE | North-South | RE | CE | Yes | [README](Architecture/RE-to-CE/README.md) | [Lab](../docs/lab-guide/index.html#ns-re-ce) |
| N-S RE to CE via BigIP | North-South | RE | CE → BigIP | Yes | [README](Architecture/RE-to-CE-bigip/README.md) | [Lab](../docs/lab-guide/index.html#ns-re-ce-bigip) |
| N-S CE via CLB | North-South | CE (CLB) | CE | Yes | [README](Architecture/CE-via-CLB/README.md) | [Lab](../docs/lab-guide/index.html#ns-ce-clb) |
| E-W CE to CE | East-West | CE | CE (remote) | Yes | [README](Architecture/CE-to-CE/README.md) | [Lab](../docs/lab-guide/index.html#ew-ce) |
| k8s Service Discovery | North-South | RE | CE → k8s | Yes | [README](Architecture/k8s-service-discovery/README.md) | [Lab](../docs/lab-guide/index.html#sd-k8s) |
| vk8s Edge Computing | North-South | RE | CE (vk8s) | Yes | [README](Architecture/vk8s/README.md) | [Lab](../docs/lab-guide/index.html#vk8s) |

## Services

| Service | Category | [Tech Docs](.) | [Lab Guide](../docs/lab-guide/index.html) |
|:---|:---|:---|:---|
| TLS Authentication (mTLS) | Security | [README](Services/tls-authentication/README.md) | [Lab](../docs/lab-guide/index.html#svc-tls-auth) |
| JWT Validation | API Security | [README](Services/jwt-validation/README.md) | [Lab](../docs/lab-guide/index.html#svc-jwt) |

## Work in Progress

| Use Case | Status | Docs |
|:---|:---|:---|
| E-W Network Connect (VPNaaS) | Idea | — |
| BigIP Service Discovery | Idea | — |
| [BGP Anycast Routing](Evaluation/bgp-anycast-routing/README.md) | Evaluating | [README](Evaluation/bgp-anycast-routing/README.md) |
| Web Application Scan | Idea | — |
