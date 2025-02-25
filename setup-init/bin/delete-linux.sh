#!/bin/bash

# Delete Infrastructure
export VES_P12_PASSWORD='REDACTED_P12_PASSWORD'
terraform -chdir="./infrastructure" destroy -auto-approve