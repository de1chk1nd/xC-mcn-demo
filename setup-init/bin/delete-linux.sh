#!/bin/bash

# Delete Infrastructure
export VES_P12_PASSWORD='***REMOVED***'
rm ./setup-init/.xC/xc-curl.crt.pem
terraform -chdir="./infrastructure" destroy -auto-approve