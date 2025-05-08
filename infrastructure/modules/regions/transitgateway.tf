# TGW Resource
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for Site Transfer"
  amazon_side_asn                 = 65000
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.student}-xC-mcn-tgw"
  }
}

# Site Transfer TGW VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "xC-mcn-main" {
  subnet_ids         = [aws_subnet.xC-mcn-site-transfer-tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.xC-mcn-site.id
  
  dns_support                   = "enable"
  ipv6_support                  = "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  
  tags = {
    Name = "tgw-attachment-site-transfer"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "xC-mcn-app" {
  subnet_ids         = [aws_subnet.xC-mcn-app-subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.xC-app-site.id
  
  dns_support                   = "enable"
  ipv6_support                  = "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  
  tags = {
    Name = "tgw-attachment-site-transfer"
  }
}