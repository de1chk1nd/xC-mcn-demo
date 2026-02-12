# Create vk8s
export VES_P12_PASSWORD='REDACTED_P12_PASSWORD'
terraform -chdir="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/terraform" fmt
terraform -chdir="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/terraform" init
terraform -chdir="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/terraform" plan
terraform -chdir="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/terraform" apply -auto-approve


# Create Workload
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/etc/workload.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/workloads


# Create public Service
## Set Environment & Substitute JSON File
export MCN_CE_EU_CENTRAL1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')

envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/etc/__template_origin-vk8s-eu-central.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-central.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/etc/__template_origin-vk8s-eu-west.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-west.json"

## Create Pool
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools

## Create Loadbalancer
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/etc/lb-vk8s-eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/etc/lb-vk8s-eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers


# Delete public Service
## Loadbalancer
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-vk8s-eu-central
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-vk8s-eu-west

## Pools
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools/origin-vk8s-eu-central
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/origin_pools/origin-vk8s-eu-west

## local tmp files
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-central.json"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/payload_final_eu-west.json"


# Delete Workload
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/workloads/echo-aws


# Delete vk8s
export VES_P12_PASSWORD='REDACTED_P12_PASSWORD'
terraform -chdir="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/vk8s/terraform" destroy -auto-approve