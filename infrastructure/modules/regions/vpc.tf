resource "aws_vpc" "xC-mcn-site" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name  = "${var.student}-xC-mcn-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.xC-mcn-site.id
  tags = {
    Name  = "${var.student}-xC-mcn-default-sg"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.xC-mcn-site.default_network_acl_id

  tags = {
    Name  = "${var.student}-xC-mcn-default-sg"
  }

}