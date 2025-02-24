# Demo for xC North-South Loadbalancer - RE to CE
This Demo will create several HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer. A WAF will be attached to ech LB.

&nbsp;

## Create Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/bin/setup.sh"
```

&nbsp;

## GET Loadbalancer
### List all Loadbalancer
```shell

curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers
```

&nbsp;

### Get Config of Loadbalancer (example lb-nginx-west) 
```shell

curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-nginx-west
```


&nbsp;

## Delete Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/bin/delete.sh"
```
