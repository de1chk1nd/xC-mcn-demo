output "etc-hosts" {
  value = <<EOF
# AWS lab section
# ubuntu - server
${module.eu-central-1.xC-mcn-site-ubuntu-01-eip}     ubuntu-01-eu-central-1.de1chk1nd-lab.aws
${module.eu-central-1.xC-mcn-site-ubuntu-02-eip}     ubuntu-02-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-ubuntu-01-eip}        ubuntu-01-eu-west-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-ubuntu-02-eip}        ubuntu-02-eu-west-1.de1chk1nd-lab.aws

# BIG-IP MGMT
${module.eu-central-1.xC-mcn-site-bigip-mgmt-eip}     bigip-mgmt-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-bigip-mgmt-eip}        bigip-mgmt-eu-west-1.de1chk1nd-lab.aws

# BIG-IP Service 1
${module.eu-central-1.Service-1-via-BigIP}     service-bigip-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.Service-1-via-BigIP}        service-bigip-eu-west-1.de1chk1nd-lab.aws

# BIG-IP Service 2
${module.eu-central-1.Service-2-via-BigIP}     service-bigip-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.Service-2-via-BigIP}        service-bigip-eu-west-1.de1chk1nd-lab.aws

# AWS NLB IP / Application Names to resolve to NLB IP >> CE IP
${module.eu-central-1.nlb_ip}     app-1.eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.nlb_ip}        app-1.eu-west-1.de1chk1nd-lab.aws

# Uncomment (comment above) for direct EIP Access to MCN (no cLB)
# ${module.eu-central-1.mcn_ip_gw01}     app-1.eu-central-1.de1chk1nd-lab.aws
# ${module.eu-west-1.mcn_ip_gw01}        app-1.eu-west-1.de1chk1nd-lab.aws


EOF
}

output "xC-MCN-CE-EU-CENTRAL1-GW01" {
  value = module.eu-central-1.xC-Site-Name-gw01
}

output "xC-MCN-CE-EU-CENTRAL1-GW02" {
  value = module.eu-central-1.xC-Site-Name-gw02
}

output "xC-MCN-CE-EU-CENTRAL1" {
  value = module.eu-central-1.nlb_dns
}

output "xC-MCN-CE-EU-WEST1-GW01" {
  value = module.eu-west-1.xC-Site-Name-gw01
}

output "xC-MCN-CE-EU-WEST1-GW02" {
  value = module.eu-west-1.xC-Site-Name-gw02
}

output "xC-MCN-CE-EU-WEST1" {
  value = module.eu-west-1.nlb_dns
}

output "BigIP-MGMTip-private-eu-central-1" {
  value = module.eu-central-1.BigIP-MGMTip-private
}

output "BigIP-MGMTip-private-eu-west-1" {
  value = module.eu-west-1.BigIP-MGMTip-private
}

output "BigIP-MGMTip-nlb-private-eu-central-1" {
  value = module.eu-central-1.nlb_bigip_dns
}

output "BigIP-MGMTip-nlb-private-eu-west-1" {
  value = module.eu-west-1.nlb_bigip_dns
}

output "ubuntu-01-nlb-private-eu-central-1" {
  value = module.eu-central-1.nlb_ubuntu-01_dns
}

output "ubuntu-02-nlb-private-eu-central-1" {
  value = module.eu-central-1.nlb_ubuntu-02_dns
}

output "ubuntu-01-nlb-private-eu-west-1" {
  value = module.eu-west-1.nlb_ubuntu-01_dns
}

output "ubuntu-02-nlb-private-eu-west-1" {
  value = module.eu-west-1.nlb_ubuntu-02_dns
}