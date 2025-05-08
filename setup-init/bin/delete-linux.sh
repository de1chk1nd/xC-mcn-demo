#!/bin/bash

# Delete Infrastructure
export VES_P12_PASSWORD='REDACTED_P12_PASSWORD'
rm ./setup-init/.xC/xc-curl.crt.pem
terraform -chdir="./infrastructure" destroy -auto-approve