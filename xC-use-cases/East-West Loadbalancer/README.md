Basic Loadbalancer
	> E/W
		lb4:
			name	: lb-api-int-west
			domains	: remote-web.de1chk1nd-mcn.aws
			lb-type	: http
			origin	: m-petersen/origin-aws-web-eu-central-1
			VIP Adv.:
				Site Network	: inside
								system/de1chk1nd-aws-[west-AWS-Site]
		
		lb5:
			name	: lb-api-int-central
			domains	: remote-web.de1chk1nd-mcn.aws
			origin	: m-petersen/origin-aws-web-eu-west-1
			VIP Adv.:
				Site Network	: inside
				Site Reference	: system/de1chk1nd-aws-[central-AWS-Site]	

		= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		curl --silent remote-web.de1chk1nd-mcn.aws | grep "Server address"

# # # # #
#
# TEST: curl --silent remote-web.de1chk1nd-mcn.aws | grep "Server address"
#
# # # # #


# Create Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer/bin/setup.sh"


# Delete Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer/bin/delete.sh"