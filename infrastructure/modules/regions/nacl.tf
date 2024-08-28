resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.xC-mcn-site.id

  subnet_ids = [ aws_subnet.xC-mcn-site-subnet.id ]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 101
    action     = "allow"
    cidr_block = "172.16.0.0/12"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 102
    action     = "allow"
    cidr_block = "192.168.0.0/16"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    #cidr_block = var.student_ip
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name  = "${var.student}-${var.region}-xC-mcn-nacl"
  }

}