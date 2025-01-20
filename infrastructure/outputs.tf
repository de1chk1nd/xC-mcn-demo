output "etc-hosts" {
  value = <<EOF
# AWS lab section
# ubuntu - server
${module.eu-central-1.xC-mcn-site-ubuntu-eip}     ubuntu-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-ubuntu-eip}        ubuntu-eu-west-1.de1chk1nd-lab.aws

# BIG-IP MGMT
${module.eu-central-1.xC-mcn-site-bigip-mgmt-eip}     bigip-mgmt-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-bigip-mgmt-eip}        bigip-mgmt-eu-west-1.de1chk1nd-lab.aws

# BIG-IP Service 1
${module.eu-central-1.Service-1-via-BigIP}     service-bigip-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.Service-1-via-BigIP}        service-bigip-eu-west-1.de1chk1nd-lab.aws

# BIG-IP Service 2
${module.eu-central-1.Service-2-via-BigIP}     service-bigip-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.Service-2-via-BigIP}        service-bigip-eu-west-1.de1chk1nd-lab.aws

EOF
}

output "xC-MCN-CE-EU-CENTRAL1" {
  value = module.eu-central-1.xC-Site-Name
}

output "xC-MCN-CE-EU-WEST1" {
  value = module.eu-west-1.xC-Site-Name
}

output "BigIP-MGMTip-private-eu-central-1" {
  value = module.eu-central-1.BigIP-MGMTip-private
}

output "BigIP-MGMTip-private-eu-west-1" {
  value = module.eu-west-1.BigIP-MGMTip-private
}