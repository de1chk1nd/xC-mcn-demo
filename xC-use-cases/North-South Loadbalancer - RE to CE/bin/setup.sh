#!/bin/bash

# Create Loadbalancer
## lb-nginx-central.json
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-nginx-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## lb-nginx-west.json
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-nginx-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## lb-nginx.json
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-nginx.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## lb-echo-ssl-central.json
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-echo-ssl-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## lb-echo-ssl-west.json
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE to CE/etc/lb-echo-ssl-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers