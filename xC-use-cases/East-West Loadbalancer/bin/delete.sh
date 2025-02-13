#!/bin/bash

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-api-int-west

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-api-int-central

rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer/payload_final_eu-central.json"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer/payload_final_eu-west.json"