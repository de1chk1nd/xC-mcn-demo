# Demo for xC East-West Loadbalancer - CE to CE
This Demo will create several HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer. A WAF will be attached to ech LB.

&nbsp;

## Create Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer - CE to CE/bin/setup.sh"
```

&nbsp;

## Test Access
- Local AWS subnet via inside interface. Login to local ubuntu jump host and issue either command:
	```code

	curl --silent http://remote-web.de1chk1nd-mcn.aws | grep "Server address"
	```
	```code

	curl --silent "http://remote-web.de1chk1nd-mcn.aws?a=<script>"
	```

&nbsp;

## Delete Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/East-West Loadbalancer - CE to CE/bin/delete.sh"
```