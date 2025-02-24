[NGINX - eu-central]: http://app-1.eu-central-1.de1chk1nd-lab.aws
[NGINX - eu-west]: http://app-1.eu-west-1.de1chk1nd-lab.aws

[NGINX XSS - eu-central]: http://app-1.eu-central-1.de1chk1nd-lab.aws?a=<script>
[NGINX XSS - eu-west]: http://app-1.eu-west-1.de1chk1nd-lab.aws?a=<script>


# Demo for xC North-South Loadbalancer - CE only
This Demo will create a HTTP Lodbalancer via API to build ingress CE and egress CE on AWS HTTP Loadbalancer. 

A WAF will be attached to ech LB.

Goal is to ***terminate*** client sessions in CE - either via public cloud loadbalancer or directly via internal request (SaaS managed local WAAP)

&nbsp;

## Create Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/bin/setup.sh"
```

&nbsp;

## Test Access
- public Internet (via local CE)
| App						| Link App				| Link App XSS  			|
|:--------------------------|:----------------------|:--------------------------|
| NGINX in AWS eu-central	| [NGINX - eu-central]  | [NGINX XSS - eu-central]	|
| NGINX in AWS  eu-west     | [NGINX - eu-west]		| [NGINX XSS - eu-west]		|

&nbsp;

- Local AWS subnet via inside interface. Login to local ubuntu jump host and issue either command:
	```code

	curl --silent http://local-web.de1chk1nd-mcn.aws | grep "Server address"
	```
	```code

	curl --silent "http://local-web.de1chk1nd-mcn.aws?a=<script>"
	```

&nbsp;

## Delete Loadbalancer
```shell

"/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - CE via CLB/bin/delete.sh"
```