#!/bin/bash

# Get NLB IP
export NLB_DNS_EU_WEST1=$(terraform -chdir="./infrastructure" output BigIP-MGMTip-nlb-private-eu-west-1 | tr -d '\"')
/usr/bin/ssh -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws "HOST_TO_LOOKUP='$NLB_DNS_EU_WEST1'; sudo nslookup \$HOST_TO_LOOKUP" | grep "Address:" | grep -v "#53"