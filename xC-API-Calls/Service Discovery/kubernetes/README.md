# Get Remote Kubeconfig Files
/usr/bin/ssh -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-central-1.de1chk1nd-lab.aws 'sudo kubectl config view --flatten' > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/kubeconfig-eu-central"

/usr/bin/ssh -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws 'sudo kubectl config view --flatten' > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/kubeconfig-eu-west"


# Create Environment Variables (kubeconfig and xC Sites)
export KUBECONFIG_EU_CENTRAL1=$(base64 "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/kubeconfig-eu-central" | tr -d '\n')
export KUBECONFIG_EU_WEST1=$(base64 "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/kubeconfig-eu-west" | tr -d '\n')

export MCN_CE_EU_CENTRAL1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-CENTRAL1 | tr -d '\"')
export MCN_CE_EU_WEST1=$(terraform -chdir="./infrastructure" output xC-MCN-CE-EU-WEST1 | tr -d '\"')

## Optional
echo $KUBECONFIG_EU_CENTRAL1 | xclip -sel clip
echo $KUBECONFIG_EU_WEST1 | xclip -sel clip

echo $MCN_CE_EU_CENTRAL1
echo $MCN_CE_EU_WEST1

# Substitute JSON File
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/__template_sd_eu-central.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-central.json"
envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/etc/__template_sd_eu-west.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-west.json"

# API Call
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys

curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys

# Set Up Origin Pool & Loadbalancer

Origin Pool
    > k8s
        origin1:
            name: origin-k8s-central
            origin-server:
                Type: K8s Service Name of Origin Server on given Sites
                Service: app-v1-nginx-svc.simple-web-nginx
                Site: system/de1chk1nd-ebca-aws-eu-central-1
                Network: Outside
            Port: 8080   
        origin2:
            name: origin-k8s-west
            origin-server:
                Type: K8s Service Name of Origin Server on given Sites
                Service: app-v1-nginx-svc.simple-web-nginx
                Site: system/de1chk1nd-9142-aws-eu-west-1
                Network: Outside
            Port: 8080


Basic Loadbalancer (https/autocert)
	> k8s
		lb1:
			name	: lb-k8s-central
			domains	: k8s-central.edge.de1chk1nd.de
			origin	: m-petersen/origin-k8s-eu-central-1
		lb2:
			name	: lb-k8s-west
			domains	: k8s-west.edge.de1chk1nd.de
			origin	: m-petersen/origin-k8s-eu-west-1
		lb3:
			name	: lb-k8s
			domains	: k8s.edge.de1chk1nd.de
			origin	: 
				m-petersen/origin-k8s-eu-west-1
				m-petersen/origin-k8s-eu-central-1


# DELETE
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-central
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/system/discoverys/sd-k8s-de1chk1nd-eu-west


rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-central.json"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/payload_final_eu-west.json"


rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/kubeconfig-eu-central"
rm "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/Service Discovery/kubernetes/kubeconfig-eu-west"

