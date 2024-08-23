resource "aws_network_interface" "xC-mcn-site-ubuntu-public" {
  subnet_id       = aws_subnet.xC-mcn-site-subnet.id
  security_groups = [aws_security_group.xC-mcn-site-allow-ubuntu.id]
  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-public-nic"
  }
}

resource "aws_eip" "xC-mcn-site-ubuntu-eip" {
  network_interface = aws_network_interface.xC-mcn-site-ubuntu-public.id
  vpc               = true

  depends_on = [
    aws_network_interface.xC-mcn-site-ubuntu-public,
    aws_instance.xC-mcn-site-ubuntu
  ]

  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-public-eip"
  }
}

data "template_file" "user_data_nginx" {
  template = file("${path.module}/etc/ubuntu/ubuntu.tmpl")
  vars = {
    region                = var.region
  }
}

resource "aws_instance" "xC-mcn-site-ubuntu" {
  ami               = var.ubuntu_ami
  instance_type     = "t2.xlarge"
  availability_zone = "${var.region}a"
  key_name          = aws_key_pair.generated_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-site-ubuntu-public.id
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
 
  user_data = data.template_file.user_data_nginx.rendered 

  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu"
  }
}