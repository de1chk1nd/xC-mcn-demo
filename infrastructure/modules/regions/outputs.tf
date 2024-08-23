output "xC-mcn-site-ubuntu-eip" {
  description = "List of BIG-IP management addresses"
  value       = aws_eip.xC-mcn-site-ubuntu-eip.public_ip
}

output "xC-mcn-site-vpc_id" {
  description = "List of BIG-IP management addresses"
  value       = aws_vpc.xC-mcn-site.id
}

output "xC-mcn-site-subnet_id" {
  description = "List of BIG-IP management addresses"
  value       = aws_subnet.xC-mcn-site-subnet.id
}