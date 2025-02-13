#!/bin/bash
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-central
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-west

rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-central.json"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-west.json"

rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-central"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-west"