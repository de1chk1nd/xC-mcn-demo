#!/bin/bash

# Delete Loadbalancer
## lb-nginx-central
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-bigip-echo-eu-central


## lb-nginx-west
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-bigip-echo-eu-west