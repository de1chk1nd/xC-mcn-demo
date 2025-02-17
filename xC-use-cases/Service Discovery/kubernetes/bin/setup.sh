#!/bin/bash

# Get Remote Kubeconfig Files
/usr/bin/ssh -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-central-1.de1chk1nd-lab.aws 'sudo kubectl config view --flatten' > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-central"
/usr/bin/ssh -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws 'sudo kubectl config view --flatten' > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-west"

# Create Environment Variables (kubeconfig and xC Sites)
export KUBECONFIG_EU_CENTRAL1=$(base64 "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-central" | tr -d '\n')
export KUBECONFIG_EU_WEST1=$(base64 "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/kubeconfig-eu-west" | tr -d '\n')

export MCN_CE_EU_CENTRAL1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')

# Substitute JSON File
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/__template_sd_eu-central.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-central.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/__template_sd_eu-west.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-west.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/__template_origin_eu-central.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_origin_eu-central.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/__template_origin_eu-west.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_origin_eu-west.json"


# Create Service Discovery
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys

sleep 5

# Create Pool
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'xC-use-cases/Service Discovery/kubernetes/payload_final_origin_eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/payload_final_origin_eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools

sleep 5

# Create Loadbalancer
curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/lb-k8s-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/lb-k8s-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

curl --silent --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'***REMOVED***' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/etc/lb-k8s.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers