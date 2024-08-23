output "etc-hosts" {
  value = <<EOF
# AWS lab section
# ubuntu - server
${module.eu-central-1.xC-mcn-site-ubuntu-eip}     ubuntu-eu-central-1.de1chk1nd-lab.aws
${module.eu-west-1.xC-mcn-site-ubuntu-eip}     ubuntu-eu-west-1.de1chk1nd-lab.aws

EOF
}