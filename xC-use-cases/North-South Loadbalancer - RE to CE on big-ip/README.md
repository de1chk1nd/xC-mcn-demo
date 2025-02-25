# Demo for xC North-South Loadbalancer - RE to CE via local BigIP
This Demo will create two HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer - forwarding traffic to local BigIP w/o Service Discovery.

A ***Wep Application Firewall*** default policy will be attached to each HTTP  Loadbalancer.

&nbsp;

## Create Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/setup.sh"
```

&nbsp;

## Test / Verify
- Check for Header: ***custom-header***

&nbsp;

## Delete Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/bin/delete.sh"
```