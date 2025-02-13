Basic Loadbalancer (https/autocert)
	> N/S
		lb2:
			name	: lb-api-central
			domains	: api-central.edge.de1chk1nd.de
			origin	: m-petersen/origin-aws-web-eu-central-1

		lb1:
			name	: lb-api-west
			domains	: api-west.edge.de1chk1nd.de
			origin	: m-petersen/origin-aws-web-eu-west-1
		
		lb3:
			name	: lb-api
			domains	: api.edge.de1chk1nd.de
			origin	: 
				m-petersen/origin-aws-web-eu-west-1
				m-petersen/origin-aws-web-eu-central-1
			
# # # # #
# # # # #

# Create Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer/bin/setup.sh"


# List
## List all Loadbalancer
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers

## Get Config of Loadbalancer (example lb-api-west) 
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-api-west


# Delete Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer/bin/delete.sh"