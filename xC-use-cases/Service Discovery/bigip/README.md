[BigIP - eu-central]: https://bigip-mgmt-eu-central-1.de1chk1nd-lab.aws 
[BigIP - eu-west]: https://bigip-mgmt-eu-west-1.de1chk1nd-lab.aws

# Service Discovery - BipIP Virtual Server
This Lab will create a BigIP Service Discovery Object to get local BigIP Services.

> __**ATTENTION:**__ **!!!!** This feature is still ***Early Access*** (Bugs included). Use with caution and as described below **!!!!**

&nbsp;

## Get BigIP Management IP
- EU-Central-1
    ```shell

    "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/bigip/bin/get-nlb-eu-central.sh"
    ```

- EU-West-1
    ```shell

    "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/Service Discovery/bigip/bin/get-nlb-eu-west.sh"
    ```

&nbsp;

## Delete BigIP Services
> __**ATTENTION:**__ **!!!!** AS3 not yet supported - please Delete all VS in **xcmcnlab** partition and create a service manually **!!!!**

&nbsp;

- ***Access to Devices from external:***
    | Device                    	 		 | Username | Password (lab-default)  |
    |:---------------------------------------|:---------|:------------------------|
    | [BigIP - eu-central]  				 | admin    | REDACTED_P12_PASSWORD         |
    | [BigIP - eu-west]       				 | admin    | REDACTED_P12_PASSWORD         |

- Note Down IP-Address of **echo443tlspass**

- Delete all VS

- Create a VS:
    - Name: echo443tlspass
    - IP Address
    - Port 443
    - HTTP Profile (Client)
    - clientssl profile
    - serverssl profile
    - AutoSNAT
    - Pool: ***p_echo_10443_https*** 
    - iRule: /xcmcnlab/A1/Add_HTTPheader

&nbsp;

## Create BigIP Service Discovery
- BigIP SD ***EU-Central***
    - ***Name:*** sd-bigip-de1chk1nd-central
    - ***site:*** system/de1chk1nd-****-aws-eu-central-1
    - ***Type:*** Site Local Network

    - ***Classic BIG-IP Discovery Configuration:***
        - Name: bigip-aws-central-1
        - MGMT IP: 10.0.20.* (IP!!!)
        - Username: admin
        - Password: REDACTED_P12_PASSWORD 

&nbsp;

- BigIP SD ***EU-West***
    - ***Name:*** sd-bigip-de1chk1nd-central
    - ***site:*** system/de1chk1nd-****-aws-eu-west-1
    - ***Type:*** Site Local Network

    - ***Classic BIG-IP Discovery Configuration:***
        - Name: bigip-aws-eu-west-1
        - MGMT IP: 172.16.20.* (IP!!!)
        - Username: admin
        - Password: REDACTED_P12_PASSWORD 

&nbsp;

## Create Origin & HTTP-Loadbalancer

t.b.d.