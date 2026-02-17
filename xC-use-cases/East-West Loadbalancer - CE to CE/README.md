# Demo for xC East-West Loadbalancer - CE to CE

This Demo will create several HTTP Lodbalancer via API to build ingress RE and egress CE on AWS HTTP Loadbalancer. A WAF will be attached to ech LB.

&nbsp;

***Overview:***

![Use Case - RE only](../../docs/images/use-cases/CE-to-CE.png)

> Remember:
> - <span style="color: green">**EU Central-1**</span> HTTP Loadbalancer **>>>** <span style="color: red">**EU West-1**</span> Origin Pool
> - <span style="color: red">**EU West-1**</span> HTTP Loadbalancer **>>>** <span style="color: green">**EU Central-1**</span> Origin Pool

&nbsp;

## Create Loadbalancer

```shell

"xC-use-cases/East-West Loadbalancer - CE to CE/bin/setup.sh"
```

&nbsp;

## Test Access

- SSH to web server (web-01 eu-central-1 and web-01 eu-west-01)

    ```bash
    # SSH to eu-central-1 web 01 only
    "xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" central
    # SSH to eu-west-1 web 01 only
    "xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" west
    # Open both in separate terminal tabs
    "xC-use-cases/East-West Loadbalancer - CE to CE/bin/ssh-webservers.sh" both
    ```

  > Using CE01 only, as no internal Loadbalancer was created for this demo

&nbsp;

- Local AWS subnet via inside interface. Login to local ubuntu jump host and issue either command:

  ```code
  curl --silent http://remote-web.de1chk1nd-mcn.aws | grep "Server name"
  ```

  ```code
  curl --silent "http://remote-web.de1chk1nd-mcn.aws?a=<script>"
  ```

&nbsp;

## Delete Loadbalancer

```shell
"xC-use-cases/East-West Loadbalancer - CE to CE/bin/delete.sh"
```
