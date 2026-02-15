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
  - incl. Web App Firewall
