########################################################################
# Subnet 1
########################################################################

resource "aws_subnet" "xC-mcn-site-subnet" {
  vpc_id                  = aws_vpc.xC-mcn-site.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name  = "${var.student}-xC-mcn-subnet"
  }
}