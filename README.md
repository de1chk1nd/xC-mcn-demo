[Use Cases]: xC-use-cases/README.md
[BigIP - eu-central]: https://bigip-mgmt-eu-central-1.de1chk1nd-lab.aws 
[BigIP - eu-west]: https://bigip-mgmt-eu-west-1.de1chk1nd-lab.aws

# xC-mcn-demo - Lab Introduction & Set Up
Welcome to my lab. This lab contains many f5 xC app solution & use cases. Pre-Configured and prepared to be build in AWS just within a couple of minutes.

The installation is failry simple and based on a local python script to deploy the whole infrastructure.

&nbsp;

The lab set up uses two public- and one privat subnets. By default we are going to set up a basic insfrastrucure in two different AWS regions: **eu-central-1** and **eu-west-1**.

&nbsp;

***Main Componentes:***
- Dual-Homed (SLo and SLi) xc Customer Edge
- 3-NIC (Mgmt, External, Internal) BigIP vAppliance with Best License
- Single NIC (Internal) Ubuntu Server with Docker and minikube

&nbsp;

The server are acompanied by AWS Services like NLB, Route53 (private zone), NAT Gateway, ...

For the sake of simplicity, all devices are spread accross ONE Availability Zone.

&nbsp;

***Overview:***

![AWS Lab Overview](docs/images/overview-aws-lab.png)

&nbsp;

---

## xC-mcn-demo - Installation
Download the repository and "cd" into the root ***xC-mcn-demo*** lab.

&nbsp;

1. Add/Replace AWS Auth Information into ./setup-init/config.yaml
    > __**ATTENTION:**__ Terraform expects (by default) that AWS Auth is done with profile "trerraform". This can be changed within the **config.yaml** file.

&nbsp;

2. Run setup script to deploy AWS Infrastrucure, EC2 Instances, xC Gateways and basic xC Configuration.
    ```shell
    py ./setup-init/initialize_infrastructure.py
    ```

&nbsp;

- Approx. Instllation times - need to complete before starting the labs/use-cases:
    | Process / Device      | Estimated Time      | Comment                                                             |
    |:----------------------|:--------------------|:--------------------------------------------------------------------|
    | Terraform 			| ***2-3 minutes***   | ./.                                                                 |
    | BigIP vAppliances     | ***5-7 minutes***   | check if AS3 completes L4-L7 Services: Pools, vServer in partition  |
    | xC Gateway       		| ***15-20 minutes*** | check in xC Console if Gateways are "online"                        |

&nbsp;

### Post Install
This will add entries to local /etc/hosts file to resolve FQDNs used in this repository.

[comment]: <> (#### <span style="color:blue">**Windows**</span>)

[comment]: <> (```shell)

[comment]: <> (code "C:/Windows/System32/drivers/etc/hosts")
[comment]: <> (terraform -chdir="./infrastructure" output -raw etc-hosts | Set-Clipboard)
[comment]: <> (```)

[comment]: <> (```shell)

[comment]: <> (del $Env:userprofile\.ssh\known_hosts)
[comment]: <> (powershell.exe -File "$Env:userprofile\Documents\git-repositories\xC-mcn-demo\setup-init\.ssh\ssh-key-permission_win.ps1")
[comment]: <> (```)

[comment]: <> (&nbsp;)

[comment]: <> (#### <span style="color:red">**Linux/Ubuntu**</span>)
```shell

terraform -chdir="./infrastructure" output -raw etc-hosts | xclip -sel clip
x-terminal-emulator -e 'sudo vim /etc/hosts'
```

```shell

rm ~/.ssh/known_hosts
sudo ./setup-init/.ssh/ssh-key-permission_lnx.sh
```

&nbsp;

- ***Access to Devices from external:***
    | Device                    	 		 | Username | Password (lab-default)  |
    |:---------------------------------------|:---------|:------------------------|
    | [BigIP - eu-central]  				 | admin    | REDACTED_P12_PASSWORD         |
    | [BigIP - eu-west]       				 | admin    | REDACTED_P12_PASSWORD         |

    > __**ATTENTION:**__ Before you can access the AWS Devices, please add local /etc/hosts entries!

&nbsp;

---

## xC-mcn-demo - Delete
[comment]: <> (#### <span style="color:blue">**Windows**</span>)
[comment]: <> (```shell)

[comment]: <> ($Env:VES_P12_PASSWORD="REDACTED_P12_PASSWORD")
[comment]: <> (terraform -chdir="./infrastructure" destroy -auto-approve)
[comment]: <> (```)

[comment]: <> (&nbsp;)

[comment]: <> (#### <span style="color:red">**Linux/Ubuntu**</span>)
- **optional** If AWS credentials expired, update creds in ./setup-init/config.yaml and run **cred-aws.py** script
    ```shell
    py ./setup-init/cred-aws.py
    ```

&nbsp;
- Delete infrastrucure in AWS and within xC Console

    ```shell

    "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/bin/delete-linux.sh"
    ```

&nbsp;
- manually delete local hosts entry

    ```shell
    sudo vim /etc/hosts
    ```