# Demo for xC North-South Loadbalancer - RE to CE via local BigIP

This Demo will create three HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer - forwarding traffic to local BigIP w/o Service Discovery.

A ***Wep Application Firewall*** default policy will be attached to each HTTP  Loadbalancer.

&nbsp;

***Overview:***

![Use Case - RE only](../../docs/images/use-cases/RE-to-CE%20w%20bigip.png)

&nbsp;

## Create Loadbalancer

```shell

"xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/setup.sh"
```

&nbsp;

## Test / Verify

- Check for Header: ***custom-header***
- optional: create APM policy with local auth
  - BigIP FQDN: ***bigip-echo-ssl.de1chk1nd-mcn.aws***

&nbsp;

## Delete Loadbalancer

```shell

"xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/delete.sh"
```
