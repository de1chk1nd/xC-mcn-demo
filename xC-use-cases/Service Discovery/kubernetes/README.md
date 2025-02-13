# Create Service Discovery
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/bin/setup.sh"

# Set Up Origin Pool & Loadbalancer
Origin Pool
    > k8s
        origin1:
            name: origin-k8s-central
            origin-server:
                Type: K8s Service Name of Origin Server on given Sites
                Service: app-v1-nginx-svc.simple-web-nginx
                Site: system/de1chk1nd-ebca-aws-eu-central-1
                Network: Inside
            Port: 8080   
        origin2:
            name: origin-k8s-west
            origin-server:
                Type: K8s Service Name of Origin Server on given Sites
                Service: app-v1-nginx-svc.simple-web-nginx
                Site: system/de1chk1nd-9142-aws-eu-west-1
                Network: Inside
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

# DELETE Service Discovery
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/kubernetes/bin/delete.sh"