Basic Loadbalancer
	> E/W
		lb4:
			name	: lb-api-int-west
			domains	: remote-web.de1chk1nd-mcn.aws
			lb-type	: http
			origin	: m-petersen/origin-aws-web-eu-central-1
			VIP Adv.:
				Site Network	: outside
								system/de1chk1nd-aws-[west-AWS-Site]
		
		lb5:
			name	: lb-api-int-central
			domains	: remote-web.de1chk1nd-mcn.aws
			origin	: m-petersen/origin-aws-web-eu-west-1
			VIP Adv.:
				Site Network	: outside
				Site Reference	: system/de1chk1nd-aws-[central-AWS-Site]	

		= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		curl --silent remote-web.de1chk1nd-mcn.aws | grep "Server address"

# # # # #
# # # # #

# Create Loadbalancer
## lb-api-west.json
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/East-West Loadbalancer/lb-api-int-west.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers


## lb-api-central.json
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -i -X POST -H 'Content-Type: application/json' -d @'/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-API-Calls/East-West Loadbalancer/lb-api-int-central.json' \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers


/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/ssh-key-permission_lnx.sh


# Delete
## lb-api-west
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-api-int-west


## lb-api-central
curl --cert /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/xc-curl.crt.pem:'REDACTED_P12_PASSWORD' \
    -I -X DELETE \
    https://f5-emea-ent.console.ves.volterra.io/api/config/namespaces/m-petersen/http_loadbalancers/lb-api-int-central

