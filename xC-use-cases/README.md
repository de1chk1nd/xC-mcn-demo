# xC Use Cases

A collection of F5 Distributed Cloud (xC) use cases for the xC-mcn-demo lab. Each use case has automated `setup.sh` and `delete.sh` scripts.

> **ATTENTION:** The full HTML Lab Guide lives at **[docs/lab-guide/index.html](../docs/lab-guide/index.html)**.
> It includes Quick Start, Detailed Setup, and all Use Case steps in one place.

> **All use cases require the base infrastructure to be deployed first.** See the [main README](../README.md) for installation instructions.

## Quick Reference

| Use Case | Direction | Ingress | Egress | WAF | Automation |
|:---|:---|:---|:---|:---|:---|
| [N-S RE only](#ns-re-only) | North-South | RE | Internet | Yes | `setup.sh` / `delete.sh` |
| [N-S RE to CE](#ns-re-to-ce) | North-South | RE | CE | Yes | `setup.sh` / `delete.sh` |
| [N-S RE to CE via BigIP](#ns-re-to-ce-bigip) | North-South | RE | CE → BigIP | Yes | `setup.sh` / `delete.sh` |
| [N-S CE via CLB](#ns-ce-via-clb) | North-South | CE (CLB) | CE | Yes | `setup.sh` / `delete.sh` |
| [E-W CE to CE](#ew-ce-to-ce) | East-West | CE | CE (remote) | Yes | `setup.sh` / `delete.sh` |
| [Service Discovery k8s](#sd-k8s) | North-South | RE | CE → k8s | No | `setup.sh` / `delete.sh` |
| [vk8s Edge Computing](#vk8s) | North-South | RE | CE (vk8s) | No | `setup.sh` / `delete.sh` |

---

## North-South Use Cases

### <a name="ns-re-only"></a> SaaS Only - RE (Regional Edge)

[**Go to use case →**](North-South%20Loadbalancer%20-%20RE/README.md)

Public HTTP load balancer via Regional Edge with DNS service discovery of AWS NLB names. Traffic never touches a Customer Edge.

- 1 public FQDN
- Origin pool with public DNS name of both region NLBs
- Web Application Firewall attached

### <a name="ns-re-to-ce"></a> Hybrid - RE to CE (Customer Edge)

[**Go to use case →**](North-South%20Loadbalancer%20-%20RE%20to%20CE/README.md)

Public HTTP load balancers via Regional Edge with egress through Customer Edge to private backend servers.

- 3 public FQDNs (eu-central only, eu-west only, both regions)
- Origin pool with private DNS name of internal web server
- Web Application Firewall attached

### <a name="ns-re-to-ce-bigip"></a> Hybrid - RE to CE via BigIP

[**Go to use case →**](North-South%20Loadbalancer%20-%20RE%20to%20CE%20on%20big-ip/README.md)

Public HTTP load balancers via Regional Edge, egress through Customer Edge to a local **BIG-IP** appliance. Demonstrates "better together" integration.

- 2 public FQDNs (one per AWS region)
- Origin pool with private DNS of BIG-IP virtual server
- iRule header manipulation (optional: APM local auth policy)

### <a name="ns-ce-via-clb"></a> Local - CE via Cloud Load Balancer

[**Go to use case →**](North-South%20Loadbalancer%20-%20CE%20via%20CLB/README.md)

Client sessions terminated directly at the Customer Edge -- either via a public cloud load balancer (NLB) or via internal request. SaaS-managed local WAAP without Regional Edge.

- Private FQDN on local Customer Edge
- Origin server via local Customer Edge
- NLB distributes traffic to CE nodes
- Web Application Firewall attached

---

## East-West Use Cases

### <a name="ew-ce-to-ce"></a> CE to CE - Cross-Region

[**Go to use case →**](East-West%20Loadbalancer%20-%20CE%20to%20CE/README.md)

Internal HTTP load balancers for east-west traffic between Customer Edge sites across AWS regions. No VPC peering -- connectivity provided entirely by the xC fabric.

- 2 private FQDNs on local Customer Edge (one per region)
- Each LB routes to the origin pool in the **opposite** region
- Web Application Firewall attached

---

## Service Discovery

### <a name="sd-k8s"></a> Kubernetes Service Discovery

[**Go to use case →**](Service%20Discovery/kubernetes/README.md)

Kubernetes service discovery via kubeconfig for local minikube clusters running on CE sites. Discovered services are exposed through HTTP load balancers.

- K8s service discovery via kubeconfig (base64-encoded)
- 3 public FQDNs (eu-central only, eu-west only, both regions)
- Origin pool with k8s service discovery (NodePort)

---

## Edge Computing

### <a name="vk8s"></a> vk8s - Managed Namespace

[**Go to use case →**](vk8s/README.md)

Deploy container workloads to CE sites using F5 xC virtual Kubernetes (vk8s). Pods run directly on Customer Edge nodes in a managed namespace.

- vk8s cluster with workload deployed to both CE sites
- 2 public FQDNs for eu-central and eu-west container workloads
- Origin pool pointing to local container workload

---

## Work in Progress

> The following use cases are not yet fully automated or documented.

| Use Case | Status |
|:---|:---|
| [E-W Network Connect (VPNaaS)](East-West%20Network%20Connect/README.md) | WIP -- route to remote network |
| [BigIP Service Discovery](Service%20Discovery/bigip/README.md) | WIP |
| [mTLS + cert info](misc/mTLS/README.md) | Reference / misc |
| [API Security - JWT validation](misc/jwt-validation/README.md) | Reference / misc |
| [Web Application Scan - Juice Shop](Web%20Application%20Scan/README.md) | Reference / misc |
