resource "aws_network_interface" "xC-mcn-app-ubuntu" {
  subnet_id       = aws_subnet.xC-mcn-app-subnet.id
  security_groups = [aws_security_group.xC-mcn-app-allow-linux.id]
  tags = {
    Name  = "${var.student}-xC-mcn-app-ubuntu-public-nic"
  }
}

data "template_file" "user_data_app_nginx" {
  template = file("${path.module}/etc/ubuntu/ubuntu_app.tmpl")
  vars = {
    region                = var.region
  }
}

resource "aws_instance" "xC-mcn-app-ubuntu" {
  ami               = var.ubuntu_ami
  instance_type     = "t2.xlarge"
  availability_zone = "${var.region}a"
  key_name          = aws_key_pair.generated_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-app-ubuntu.id
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
 
  user_data = data.template_file.user_data_app_nginx.rendered 

  tags = {
    Name  = "${var.student}-xC-mcn-app-ubuntu"
  }
}