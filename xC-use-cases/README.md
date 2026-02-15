# Overview XC Use Cases

A list of XC Use Cases to use with the xc-mcn-lab

&nbsp;

## Platform & Architecure Security basics

### Simple Examples / common use cases

- [SaaS only - N-S PoP (RE) only](North-South%20Loadbalancer%20-%20RE/README.md)
  - 1 public FQDN with known DNS name
  - origin pool with public DNS name of BOTH Region NLBs
  - incl. Web App Firewall
- [Hybrid - N-S PoP (RE) to Customer Edge (CE)](North-South%20Loadbalancer%20-%20RE%20to%20CE/README.md)
  - 3 public FQDNs (EU-Central only, EU-West only, Both)
  - origin pool with private DNS name of internal Web Server
  - incl. Web App Firewall
- [Local - E-W Customer Edge (CE) to Customer Edge (CE)](East-West%20Loadbalancer%20-%20CE%20to%20CE/README.md)
  - 2 private FQDNs (EU-Central only, EU-West) on local Customer Edge
  - origin pool with private DNS name of internal Web Server
    - <span style="color: green">**EU Central-1**</span> HTTP Loadbalancer **>>>** <span style="color: red">**EU West-1**</span> Origin Pool
    - <span style="color: red">**EU West-1**</span> HTTP Loadbalancer **>>>** <span style="color: green">**EU Central-1**</span> Origin Pool
    &nbsp;

  - incl. Web App Firewall

&nbsp;

## ***WORK IN PROGRESS BELOW***

### advanced use cases / bigip integration

- [Hybrid - N-S PoP (RE) to Customer Edge (CE) - BigIP "better together"](North-South%20Loadbalancer%20-%20RE%20to%20CE%20on%20big-ip/README.md)
  - 1 public FQDN with known DNS name
  - origin pool with private DNS name of internal Web Server ***via bigip***
- [Local - Customer Edge (CE) local termination](North-South%20Loadbalancer%20-%20CE%20via%20CLB/README.md)
  - FQDN on local Customer Edge
  - Origin Server via local Customer Edge
  - NLB to distribute traffic to Customer Edge
- [Rotuing - "VPNaaS"; Route to remote networking](East-West%20Network%20Connect/README.md)
  - Create VPN tunnel to remote network
  - access remote web server with internal IP-Address

&nbsp;

### Service Discovery

- [k8s service discovery](Service%20Discovery/kubernetes/README.md)
- [bigip service discovery](Service%20Discovery/bigip/README.md)

&nbsp;

### vk8s / Edge Computing

- [Edge Computing - Managed Namespace](vk8s/README.md)

&nbsp;

### misc. use cases

- [mTLS + cert info](misc/mTLS/README.md)
- [API-Security - jwt validation](misc/jwt-validation/README.md)
- [Web Application Scan - Juice Shop](Web%20Application%20Scan/README.md)
