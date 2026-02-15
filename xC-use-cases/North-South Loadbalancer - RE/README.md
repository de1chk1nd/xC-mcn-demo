# Demo for xC North-South Loadbalancer - RE only
This Demo will create one  HTTP Lodbalancer manually to build *ingress & egress via* **Regional Edge** HTTP Loadbalancer.

Egress will be directly via "Internet" and DNS Service Discovery (FQDN) of AWS ELB Names (EU-Central-1 and EU-West-1).

&nbsp;

A ***Wep Application Firewall*** default policy will be attached to this HTTP  Loadbalancer.

&nbsp;

***Overview:***

![Use Case - RE only](../../docs/images/use-cases/RE-only.png)

&nbsp;

## Create Origin & Loadbalancer
This lab is based on manually creating the ressources (here via JSON Import in UI).

&nbsp;

- Create <span style="color:red">**Config File**</span> to dynamically add AWS NLB DNS Recors to origin public DNS
    ```code
    "xC-use-cases/North-South Loadbalancer - RE/bin/setup.sh"
    ```

&nbsp;

- To create the <span style="color:blue">**Origin Pool**</span>, c&p content of **xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/origin-pool.json** into the JSON tab of the origin-pool create form. 

    If you have ***xclip*** installed, run following command (else, manually copy the content into your clipboard).
    ```code
    xclip -selection c < "xC-use-cases/North-South Loadbalancer - RE/etc/origin-pool.json"
    ```

&nbsp;

- To create the <span style="color:blue">**HTTP Loadbalancer**</span>, c&p content of **xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/http-loadbalancer.json** into the JSON tab of the HTTP-Loadbalancer create form. 
    
    If you have ***xclip*** installed, run following command (else, manually copy the content into your clipboard).
    ```code
    xclip -selection c < "xC-use-cases/North-South Loadbalancer - RE/etc/http-loadbalancer.json"
    ```

&nbsp;

## Delete Origin & Loadbalancer
To delete the current configuration, please

- Via xC UI, **manually** delete (in listet order):
    - HTTP-Loadbalancer 
    - Origin-Pool

&nbsp;

- Execute "delete <span style="color:red">**Config File**</span>" script, to remove local *.json files.
    ```code
    "xC-use-cases/North-South Loadbalancer - RE/bin/delete.sh"
    ```