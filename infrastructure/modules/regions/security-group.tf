resource "aws_security_group" "xC-mcn-site-allow-ubuntu" {
  name        = "allow_traffic_to_nap"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.xC-mcn-site.id
  ingress {
    description = "SSH from Student PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Web SSL Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.student_ip]
  }
  ingress {
    description = "Allow local access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-sg"
  }
}