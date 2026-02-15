########################################################################
# Main Routing Table
########################################################################

resource "aws_route_table" "xC-mcn-site-routetable" {
  vpc_id = aws_vpc.xC-mcn-site.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-lab-main.id
  }
  tags = {
    Name = "${var.student}-xC-mcn-public-route"
  }
}

resource "aws_route_table" "xC-mcn-site-routetable-priv" {
  vpc_id = aws_vpc.xC-mcn-site.id
  route {
    cidr_block           = var.remote_cidr
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv-01.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.xC-mcn-site-natgw.id
  }
  tags = {
    Name = "${var.student}-xC-mcn-private-route"
  }
}

########################################################################
# Application Routing Table
########################################################################

resource "aws_route_table" "xC-mcn-app-routetable" {
  vpc_id = aws_vpc.xC-app-site.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xC-mcn-site-app-igw.id
  }
  tags = {
    Name = "${var.student}-xC-mcn-app-public-route"
  }
}