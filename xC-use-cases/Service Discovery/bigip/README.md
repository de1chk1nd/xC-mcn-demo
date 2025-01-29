# AddBigIP

## GET MGMT IP
terraform -chdir="./infrastructure" output BigIP-MGMTip-private-eu-central-1

terraform -chdir="./infrastructure" output BigIP-MGMTip-private-eu-west-1


BigIP
    > BigIP SD
        bigip1:
            name: sd-bigip-de1chk1nd-central
            site: system/de1chk1nd-ebca-aws-eu-central-1
            Type: Site Local Network
            Classic BIG-IP Discovery Configuration:
                Name: bigip-aws-central-1
                    MGMT IP: 10.0.0.250 (IP!!!)
                    Username: admin
                    Password: ***REMOVED*** 
        bigip1:
            name: sd-bigip-de1chk1nd-central
            site: system/de1chk1nd-ebca-aws-eu-central-1
            Type: Site Local Network
            Classic BIG-IP Discovery Configuration:
                Name: bigip-aws-central-1
                    MGMT IP: 10.0.0.250 (IP!!!)
                    Username: admin
                    Password: ***REMOVED***


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