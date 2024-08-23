# xC-mcn-demo - Installation
py ./setup-init/initialize_infrastructure.py

## Post Install
code "C:/Windows/System32/drivers/etc/hosts"
terraform -chdir="./infrastructure" output -raw etc-hosts | Set-Clipboard

del $Env:userprofile\.ssh\known_hosts
powershell.exe -File "$Env:userprofile\Documents\git-repositories\xC-mcn-demo\setup-init\.ssh\ssh-key-permission_win.ps1"

AWS Console:
- Change source/destination check

login to ubuntu:
- minikube start --vm-driver=none
- kubectl apply -f https://raw.githubusercontent.com/de1chk1nd/lab-devops/main/xC/mcn-minikube/echo-app.yaml
- create kubeconfig file >> cat "certificate file" | base64

## Delete
$Env:VES_P12_PASSWORD="***REMOVED***"
terraform -chdir="./infrastructure" destroy -auto-approve

- manual
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














CERTS:

-----BEGIN RSA PRIVATE KEY-----
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
REDACTED_RSA_KEY_LINE
-----END RSA PRIVATE KEY-----

-----BEGIN CERTIFICATE-----
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
REDACTED_CERT_LINE
-----END CERTIFICATE-----


















### OLD

terraform -chdir="./infrastructure" apply -replace="module.eu-central-1.aws_instance.xC-mcn-site-ubuntu"


Change config-yaml

  ip-address: t.b.d.
  aws_access_key_id: t.b.d.
  aws_secret_access_key: t.b.d.
  aws_session_token: t.b.d.


```code
$Env:VES_P12_PASSWORD="***REMOVED***"

terraform -chdir="./infrastructure" fmt
terraform -chdir="./infrastructure" init
terraform -chdir="./infrastructure" plan
terraform -chdir="./infrastructure" apply -auto-approve
```

aws ec2 describe-instances --region eu-central-1 --filters "Name=tag:Name,Values=master-0" --query 'Reservations[].Instances[].PrivateIpAddress' --output text --profile terraform
aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:Name,Values=master-0" --query 'Reservations[].Instances[].PrivateIpAddress' --output text --profile terraform


eu-central-1    : sudo ip route add 10.10.0.0/16 via 10.1.0.145
eu-west-1       : sudo ip route add 10.1.0.0/16 via 10.10.0.92