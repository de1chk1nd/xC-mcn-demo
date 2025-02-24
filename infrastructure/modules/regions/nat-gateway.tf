########################################################################
# NAT Gateway Internet Access
########################################################################

resource "aws_nat_gateway" "xC-mcn-site-natgw" {
  allocation_id = aws_eip.xC-mcn-site-natgw-eip.id
  subnet_id     = aws_subnet.xC-mcn-site-subnet.id

  tags = {
    Owner = var.student
    Name  = "${var.student}-natgw1"
  }
}

resource "aws_eip" "xC-mcn-site-natgw-eip" {
  depends_on = [aws_internet_gateway.k8s-lab-main]
  tags = {
    Owner = var.student
    Name  = "${var.student}-nat-1"
  }
}