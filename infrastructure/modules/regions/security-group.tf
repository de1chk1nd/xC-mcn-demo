resource "aws_security_group" "xC-mcn-site-allow-linux" {
  name        = "${var.student}-xC-mcn-sg-allow-linux"
  description = "Linux Server Security Group"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "SSH from Student PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.student}-xC-mcn-sg-allow-linux"
  }
}

resource "aws_security_group" "xC-mcn-site-allow-bigip-mgmt" {
  name        = "${var.student}-xC-mcn-sg-allow-bigip-mgmt"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "SSH from Student PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.student}-xC-mcn-sg-allow-bigip-mgmt"
  }
}

resource "aws_security_group" "xC-mcn-site-allow-bigip" {
  name        = "${var.student}-xC-mcn-sg-allow-bigip"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "SSH from Student PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.student}-xC-mcn-sg-allow-bigip"
  }
}

resource "aws_security_group" "xC-mcn-site-allow-ubuntu" {
  name        = "allow_traffic_to_nap"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "SSH from Student PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "BigIP Web MGMT"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    prefix_list_ids  = [aws_ec2_managed_prefix_list.xc-was-ips.id]
  }
  ingress {
    description = "BigIP Web MGMT"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "BigIP Web MGMT"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-sg"
  }
}

resource "aws_security_group" "xC-mcn-site-ce-access-generic" {
  name        = "${var.student}-xC-mcn-sg-customer-edge-generic"
  description = "Allow traffic from/to Customer Edges"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "Customer Edge SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Customer Edge local UI"
    from_port   = 65500
    to_port     = 65500
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
      ]
  }
  egress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["159.60.141.140/32"]
    description       = "Allow TCP 443 to specific F5 IP"
  }
  egress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
      ]
  }

  tags = {
    Name  = "${var.student}-xC-mcn-sg-customer-edge-generic"
  }
}

resource "aws_security_group" "xC-mcn-site-ce-to-americas" {
  name        = "${var.student}-xC-mcn-sg-customer-edge-egress-to-americas"
  description = "Allow traffic from/to Customer Edges"
  vpc_id      = aws_vpc.xC-mcn-site.id
  egress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_americas.id]
    description       = "Allow TCP 80 to F5 Edge networks"
  }
  egress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_americas.id]
    description       = "Allow TCP 443 to F5 Edge networks"
  }
  egress {
    from_port         = 4500
    to_port           = 4500
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_americas.id]
    description       = "Allow UDP 4500 to F5 Edge networks (IPSec)"
  }
  egress {
    from_port         = 123
    to_port           = 123
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_americas.id]
    description       = "Allow UDP 123 to F5 Edge networks (NTP)"
  }
  tags = {
    Name  = "${var.student}-xC-mcn-sg-customer-edge-egress-to-americas"
  }
}

resource "aws_security_group" "xC-mcn-site-ce-to-europe" {
  name        = "${var.student}-xC-mcn-sg-customer-edge-egress-to-europe"
  description = "Allow traffic from/to Customer Edges"
  vpc_id      = aws_vpc.xC-mcn-site.id
  egress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_europe.id]
    description       = "Allow TCP 80 to F5 Edge networks"
  }
  egress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_europe.id]
    description       = "Allow TCP 443 to F5 Edge networks"
  }
  egress {
    from_port         = 4500
    to_port           = 4500
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_europe.id]
    description       = "Allow UDP 4500 to F5 Edge networks (IPSec)"
  }
  egress {
    from_port         = 123
    to_port           = 123
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_europe.id]
    description       = "Allow UDP 123 to F5 Edge networks (NTP)"
  }

  tags = {
    Name  = "${var.student}-xC-mcn-sg-customer-edge-egress-to-europe"
  }
}

resource "aws_security_group" "xC-mcn-site-ce-to-asia" {
  name        = "${var.student}-xC-mcn-sg-customer-edge-egress-to-asia"
  description = "Allow traffic from/to Customer Edges"
  vpc_id      = aws_vpc.xC-mcn-site.id
  egress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_asia.id]
    description       = "Allow TCP 80 to F5 Edge networks"
  }
  egress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_asia.id]
    description       = "Allow TCP 443 to F5 Edge networks"
  }
  egress {
    from_port         = 4500
    to_port           = 4500
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_asia.id]
    description       = "Allow UDP 4500 to F5 Edge networks (IPSec)"
  }
  egress {
    from_port         = 123
    to_port           = 123
    protocol          = "udp"
    prefix_list_ids   = [aws_ec2_managed_prefix_list.xC_asia.id]
    description       = "Allow UDP 123 to F5 Edge networks (NTP)"
  }

  tags = {
    Name  = "${var.student}-xC-mcn-sg-customer-edge-egress-to-asia"
  }
}