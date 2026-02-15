# xC-mcn-demo - Lab Introduction & Set Up

[BigIP - eu-central]: https://bigip-mgmt-eu-central-1.de1chk1nd-lab.aws
[BigIP - eu-west]: https://bigip-mgmt-eu-west-1.de1chk1nd-lab.aws
[GitHub - MCN repository]: https://github.com/de1chk1nd/xC-mcn-demo

Welcome to my lab. This lab contains many f5 xC app solution & use cases. Pre-Configured and prepared to be build in AWS just within a couple of minutes.

The installation is failry simple and based on a local python script to deploy the whole infrastructure.

&nbsp;

## Overview of AWS Demo Environment

This diagram illustrates a demo setup in AWS featuring **F5 Distributed Cloud Customer Edge (CE)** nodes. The environment is divided into a **Main VPC** and an **App VPC**, interconnected via a **Transit Gateway (TGW)**.

&nbsp;

### Components

- **Customer Edge (CE)**:
  - Deployed in both the public subnet and transfer TGW subnet.
  - Supports routing and connectivity testing.
  - Uses **BGP** to communicate with the App VPC.

- **Ubuntu Servers**:
  - Host application workloads.
  - Deployed in both the Main VPC (`ubuntu main-vpc`) and the App VPC (`ubuntu app-vpc`).
  - Accessible either locally (direct CE-to-Ubuntu communication) or remotely via BGP routing.

- **BigIP Appliances**:
  - One instance is used for **management** in a dedicated subnet.
  - Another instance supports **local traffic routing** between CE nodes and the application server.

- **Network Load Balancers (NLBs)**:
  - Distribute incoming traffic to CE nodes and BigIP instances across different subnets.

&nbsp;

### Key Use Cases

- Local traffic from CE nodes to the application in the Main VPC.
- Remote application access from CE nodes to the App VPC using BGP over the Transit Gateway.
- Routing through the local BigIP to reach the Ubuntu application server.
- ***For a complete list of use cases please check:*** [link here](xC-use-cases/README.md)

&nbsp;

This architecture showcases flexible traffic routing, high availability, and hybrid connectivity use cases using F5 Distributed Cloud and AWS components.

The servers are accompanied by AWS services such as **NLB**, **Route 53** (private hosted zone), and **NAT Gateway**.

&nbsp;

> **Note:** For simplicity, all components in this demo environment are deployed within a **single Availability Zone**.

&nbsp;

***Overview:***

![AWS Lab Overview](docs/images/overview-aws-lab-v3.png)

&nbsp;

---

## xC-mcn-demo - Installation

Download/Clone the [GitHub - MCN repository] and "cd" into the root ***xC-mcn-demo*** lab.

&nbsp;

1. Add/Replace AWS Auth Information into ***./setup-init/config.yaml***
    - aws.**aws_access_key_id**
    - aws.**aws_secret_access_key**
    - aws.**aws_session_token**

    > **ATTENTION:** Terraform expects (by default) that AWS Auth is done with profile "trerraform". This can be changed within the **config.yaml** file.

2. Run setup script to deploy AWS Infrastrucure, EC2 Instances, xC Gateways and basic xC Configuration.

    ```shell
    py ./setup-init/initialize_infrastructure.py
    ```

&nbsp;

- Approx. Instllation times - need to complete before starting the labs/use-cases:

    | Process / Device      | Estimated Time      | Comment                                                             |
    |:----------------------|:--------------------|:--------------------------------------------------------------------|
    | Terraform             | ***2-3 minutes***   | ./.                                                                 |
    | BigIP vAppliances     | ***5-7 minutes***   | check if AS3 completes L4-L7 Services: Pools, vServer in partition  |
    | xC Gateway            | ***15-20 minutes*** | check within the xC Console if Gateways are "online"                |

&nbsp;

### Post Install

This will add entries to local /etc/hosts file to resolve FQDNs used in this repository.

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

    | Device                                 | Username | Password (lab-default)  |
    |:---------------------------------------|:---------|:------------------------|
    | [BigIP - eu-central]                   | admin    | DefaultLabPwd!2026      |
    | [BigIP - eu-west]                      | admin    | DefaultLabPwd!2026      |

    > **ATTENTION:** Before you can access the AWS Devices, please add local /etc/hosts entries!

&nbsp;

---

## xC-mcn-demo - Delete

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
