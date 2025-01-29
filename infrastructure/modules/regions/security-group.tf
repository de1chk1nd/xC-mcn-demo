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
    description = "xC CE Web MGMT"
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