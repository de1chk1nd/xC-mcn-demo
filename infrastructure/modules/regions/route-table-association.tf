resource "aws_route_table_association" "xC-mcn-site-public" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.xC-mcn-site-subnet.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.xC-mcn-site-routetable.id
}

resource "aws_route_table_association" "xC-mcn-site-bigipmgmt" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.xC-mcn-site-bigip-mgmt.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.xC-mcn-site-routetable.id
}

resource "aws_route_table_association" "xC-mcn-site-private" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.xC-mcn-site-subnet-priv.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.xC-mcn-site-routetable-priv.id
}