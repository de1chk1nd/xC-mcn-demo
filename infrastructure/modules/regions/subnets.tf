########################################################################
# Subnet 1
########################################################################

resource "aws_subnet" "xC-mcn-site-subnet" {
  vpc_id                  = aws_vpc.xC-mcn-site.id
  cidr_block              = var.subnet_cidr_pub
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name  = "${var.student}-xC-mcn-subnet"
  }
}

########################################################################
# Subnet 2
########################################################################

resource "aws_subnet" "xC-mcn-site-subnet-priv" {
  vpc_id                  = aws_vpc.xC-mcn-site.id
  cidr_block              = var.subnet_cidr_priv
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    Name  = "${var.student}-xC-mcn-subnet-priv"
  }
}

########################################################################
# Subnet 2
########################################################################

resource "aws_subnet" "xC-mcn-site-bigip-mgmt" {
  vpc_id                  = aws_vpc.xC-mcn-site.id
  cidr_block              = var.subnet_cidr_mgmt
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name  = "${var.student}-xC-mcn-subnet-bigip-mgmt"
  }
}