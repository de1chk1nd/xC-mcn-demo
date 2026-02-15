# Demo for xC North-South Loadbalancer - RE to CE
This Demo will create several HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer. 

A ***Wep Application Firewall*** default policy will be attached to each HTTP  Loadbalancer.

&nbsp;

***Overview:***

![Use Case - RE only](../../docs/images/use-cases/RE-to-CE.png)

&nbsp;

## Create Loadbalancer
```shell

"xC-use-cases/North-South Loadbalancer - RE to CE/bin/setup.sh"
```

&nbsp;

## GET Loadbalancer
### List all Loadbalancer
- Issue a GET Request with your favorite API Client (need to fetch API Token, or re-use *.p12 cert from terraform)
    - GET https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

&nbsp;

### Get Config of Loadbalancer (example lb-nginx-west) 
- Issue a GET Request with your favorite API Client (need to fetch API Token, or re-use *.p12 cert from terraform)
    - GET https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-nginx-west

&nbsp;

## Delete Loadbalancer
```shell

"xC-use-cases/North-South Loadbalancer - RE to CE/bin/delete.sh"
```
