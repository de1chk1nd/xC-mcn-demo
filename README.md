# xC-mcn-demo - Installation
py ./setup-init/initialize_infrastructure.py

## Post Install
### Windows
code "C:/Windows/System32/drivers/etc/hosts"
terraform -chdir="./infrastructure" output -raw etc-hosts | Set-Clipboard

del $Env:userprofile\.ssh\known_hosts
powershell.exe -File "$Env:userprofile\Documents\git-repositories\xC-mcn-demo\setup-init\.ssh\ssh-key-permission_win.ps1"

### Linux
x-terminal-emulator -e 'sudo vim /etc/hosts'
terraform -chdir="./infrastructure" output -raw etc-hosts | Set-Clipboard

rm ~/.ssh/known_hosts
sudo ./setup-init/.ssh/ssh-key-permission_lnx.sh

### AWS Console / CLI (Change Soure-/Destination Check)
EU-WEST-1
---------
export EC2_xc_IID_EU_WEST_1=$(aws ec2 describe-instances --region eu-west-1 --filters Name=tag:ves-io-site-name,Values=de1chk1nd-aws-* Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text)
aws ec2 modify-instance-attribute --region eu-west-1 --instance-id $EC2_xc_IID_EU_WEST_1 --source-dest-check "{\"Value\": false}"

EU-CENTRAL-1
------------
export EC2_xc_IID_EU_CENTRAL_1=$(aws ec2 describe-instances --region eu-central-1 --filters Name=tag:ves-io-site-name,Values=de1chk1nd-aws-* Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text)
aws ec2 modify-instance-attribute --region eu-central-1 --instance-id $EC2_xc_IID_EU_CENTRAL_1 --source-dest-check "{\"Value\": false}"

### login to Ubuntu Server
- minikube start --vm-driver=none
- kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml
- create kubeconfig file >> cat "certificate file" | base64


## Delete
### Windows
 $Env:VES_P12_PASSWORD="REDACTED_P12_PASSWORD"
 terraform -chdir="./infrastructure" destroy -auto-approve

### Linux
 py ./setup-init/cred-aws.py

 export VES_P12_PASSWORD='REDACTED_P12_PASSWORD'
 terraform -chdir="./infrastructure" destroy -auto-approve

 x-terminal-emulator -e 'sudo vim /etc/hosts' &

### manual (if s.th. failed)
  - xC Console
    - origin pools
    - service discovery
    - AWS sites
  - AWS
    - master-0
    - NW interface
    - EIP
    - VPC
    - keyring
