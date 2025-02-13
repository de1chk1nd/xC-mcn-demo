Basic Loadbalancer (http)
	> N/S
		lb1:
			name	: lb-ce-central
			domains	: app-1.eu-central-1.de1chk1nd-lab.aws, local-web.de1chk1nd-mcn.aws
			Type	: HTTP
			origin	: m-petersen/origin-aws-web-eu-central-1
			VIP Adv.: Custom
				NW		: Inside and Outside
				Site	: system/de1chk1nd-XXXX-aws-eu-central-1

		lb2:
			name	: lb-ce-west
			domains	: app-1.eu-west-1.de1chk1nd-lab.aws, local-web.de1chk1nd-mcn.aws
			Type	: HTTP
			origin	: m-petersen/origin-aws-web-eu-west-1
			VIP Adv.: Custom
				NW		: Inside and Outside
				Site	: system/de1chk1nd-XXXX-aws-eu-west-1

# # # # #
#
# TEST: curl --silent local-web.de1chk1nd-mcn.aws | grep "Server address"
#
# # # # #

# Create Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CLB to CE/bin/setup.sh"

# Delete Loadbalancer
"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CLB to CE/bin/delete.sh"