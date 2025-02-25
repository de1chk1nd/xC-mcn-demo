#!/bin/bash

# Delete Infrastructure
export VES_P12_PASSWORD='***REMOVED***'
terraform -chdir="./infrastructure" destroy -auto-approve