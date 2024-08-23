resource "aws_route_table_association" "xC-mcn-site-public" {
  # The subnet ID to create an association.
  subnet_id = aws_subnet.xC-mcn-site-subnet.id
  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.xC-mcn-site-routetable.id
}