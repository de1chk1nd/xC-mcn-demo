# Demo for xC North-South Loadbalancer - RE to CE
This Demo will create one  HTTP Lodbalancer manually to build *ingress & egress via* **Regional Edge** HTTP Loadbalancer. 

A ***Wep Application Firewall*** default policy will be attached to this HTTP  Loadbalancer.

&nbsp;

> __**ATTENTION:**__ A public Webserver will be used for this purpose: ***echo.free.beeceptor.com***

&nbsp;

## Create Origin & Loadbalancer
- To create the Origin Pool, c&p content of ***xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/origin-pool.json*** into the JSON tab of the origin-pool create form. 

    If you have ***xclip*** installed, run following command (else, manually copy the content into your clipboard).
    ```code
    xclip -selection c < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/origin-pool.json"
    ```

&nbsp;

- To create the HTTP Loadbalancer, c&p content of ***xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/http-loadbalancer.json*** into the JSON tab of the HTTP-Loadbalancer create form. 
    If you have ***xclip*** installed, run following command (else, manually copy the content into your clipboard).
    ```code
    xclip -selection c < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/http-loadbalancer.json"
    ```

&nbsp;

## Delete Origin & Loadbalancer
Manually delete HTTP-Loadbalancer and Origin-Pool