resource "aws_internet_gateway" "k8s-lab-main" {
  vpc_id = aws_vpc.xC-mcn-site.id
  tags = {
    Name  = "${var.student}-xC-mcn-ig"
  }
}