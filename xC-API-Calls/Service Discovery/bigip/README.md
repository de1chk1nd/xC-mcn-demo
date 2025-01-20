# AddBigIP

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
                    Password: REDACTED_P12_PASSWORD
                    Network: Outside
                    Port: 8080   
        origin2:
            name: sd-bigip-de1chk1nd-west
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