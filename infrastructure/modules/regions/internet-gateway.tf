resource "aws_internet_gateway" "k8s-lab-main" {
  vpc_id = aws_vpc.xC-mcn-site.id
  tags = {
    Name  = "${var.student}-xC-mcn-igw"
  }
}

resource "aws_internet_gateway" "xC-mcn-site-app-igw" {
  vpc_id = aws_vpc.xC-app-site.id
  tags = {
    Name  = "${var.student}-xC-mcn-app-igw"
  }
}