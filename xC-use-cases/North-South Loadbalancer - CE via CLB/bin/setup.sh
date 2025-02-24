#!/bin/bash

export MCN_CE_EU_CENTRAL1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')

envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/etc/__local-lb-eu-central.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/payload_final_eu-central.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/etc/__local-lb-eu-west.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/payload_final_eu-west.json"

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/payload_final_eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/payload_final_eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers
