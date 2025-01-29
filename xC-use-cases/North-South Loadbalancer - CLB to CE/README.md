Basic Loadbalancer (http)
	> N/S
		lb1:
			name	: lb-ce-central
			domains	: app-1.eu-central-1.de1chk1nd-lab.aws
			Type	: HTTP
			origin	: m-petersen/origin-aws-web-eu-central-1
			VIP Adv.: Custom
				NW		: Inside and Outside
				Site	: system/de1chk1nd-XXXX-aws-eu-central-1

		lb2:
			name	: lb-ce-west
			domains	: app-1.eu-west-1.de1chk1nd-lab.aws
			Type	: HTTP
			origin	: m-petersen/origin-aws-web-eu-west-1
			VIP Adv.: Custom
				NW		: Inside and Outside
				Site	: system/de1chk1nd-XXXX-aws-eu-west-1


# # # # #
# # # # #

# Create Loadbalancer






