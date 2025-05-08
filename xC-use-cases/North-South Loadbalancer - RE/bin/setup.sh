#!/bin/bash

export UBUNTU_NLB_EU_CENTRAL=$(terraform -chdir="./infrastructure" output ubuntu-nlb-private-eu-central-1 | tr -d '\"')
export UBUNTU_NLB_EU_WEST=$(terraform -chdir="./infrastructure" output ubuntu-nlb-private-eu-west-1 | tr -d '\"')

envsubst < "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/__template__origin-pool.json" > "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/xC-use-cases/North-South Loadbalancer - RE/etc/origin-pool.json"