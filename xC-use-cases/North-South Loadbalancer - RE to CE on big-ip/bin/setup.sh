#!/bin/bash

# Create Loadbalancer
## lb-bigip-echo-eu-central
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/etc/lb-bigip-echo-eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## lb-bigip-echo-eu-west
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE on big-ip/etc/lb-bigip-echo-eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers