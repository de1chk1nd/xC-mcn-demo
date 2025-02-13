# Ubuntu
output "xC-mcn-site-ubuntu-eip" {
  description = "List of BIG-IP management addresses"
  value       = aws_eip.ubuntu_nlb_eip.public_ip
}

output "xC-mcn-site-bigip-mgmt-eip" {
  description = "List of BIG-IP management addresses"
  value       = aws_eip.bigip-mgmt.public_ip
}

# AWS
output "xC-mcn-site-vpc_id" {
  description = "List of BIG-IP management addresses"
  value       = aws_vpc.xC-mcn-site.id
}

output "xC-mcn-site-subnet_id" {
  description = "List of BIG-IP management addresses"
  value       = aws_subnet.xC-mcn-site-subnet.id
}

output "nlb_dns" {
  description = "DNS name of the NLB"
  value       = aws_lb.ce-nlb.dns_name
}

output "nlb_ip" {
  description = "Allocated Elastic IP"
  value       = aws_eip.ce_nlb_eip.public_ip
}

output "mcn_ip" {
  description = "Allocated Elastic IP"
  value       = aws_eip.xC-mcn-site-ubuntu-eip-v2.public_ip
}


# BigIP
output "Service-1-via-BigIP" {
  description = "List of BIG-IP management addresses"
  value       = aws_eip.bigip-ext-1.public_ip
}

output "Service-2-via-BigIP" {
  description = "List of BIG-IP management addresses"
  value       = aws_eip.bigip-ext-2.public_ip
}

output "BigIP-MGMTip-private" {
  description = "List of BIG-IP management addresses"
  value       = data.aws_network_interface.bigip-mgmt.private_ips[0]
}

# xC
output "xC-Site-Name" {
  description = "List of BIG-IP management addresses"
  value       = volterra_securemesh_site_v2.xC-mcn-smsv2-appstack.name
}