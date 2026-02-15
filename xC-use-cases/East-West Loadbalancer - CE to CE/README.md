# Demo for xC East-West Loadbalancer - CE to CE
This Demo will create several HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer. A WAF will be attached to ech LB.

&nbsp;

***Overview:***

![Use Case - RE only](../../docs/images/use-cases/CE-to-CE.png)

&nbsp;

## Create Loadbalancer
```shell

"xC-use-cases/East-West Loadbalancer - CE to CE/bin/setup.sh"
```

&nbsp;

## Test Access
- Local AWS subnet via inside interface. Login to local ubuntu jump host and issue either command:
	```code

	curl --silent http://remote-web.de1chk1nd-mcn.aws | grep "Server name"
	```
	```code

	curl --silent "http://remote-web.de1chk1nd-mcn.aws?a=<script>"
	```
	```code

	curl -v -H "Host: remote-web.de1chk1nd-mcn.aws" http://
	```


&nbsp;

## Delete Loadbalancer
```shell

"xC-use-cases/East-West Loadbalancer - CE to CE/bin/delete.sh"
```