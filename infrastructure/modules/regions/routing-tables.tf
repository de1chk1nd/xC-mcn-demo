resource "aws_route_table" "xC-mcn-site-routetable" {
  vpc_id = aws_vpc.xC-mcn-site.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-lab-main.id
  }
  tags = {
    Name  = "${var.student}-xC-mcn-public-route"
  }
}