resource "aws_network_interface" "xC-mcn-site-ubuntu-01-public" {
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  security_groups = [aws_security_group.xC-mcn-site-allow-linux.id]
  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-01-public-nic"
  }
}

resource "aws_network_interface" "xC-mcn-site-ubuntu-02-public" {
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  security_groups = [aws_security_group.xC-mcn-site-allow-linux.id]
  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-02-public-nic"
  }
}

data "template_file" "user_data_nginx-01" {
  template = file("${path.module}/etc/ubuntu/ubuntu-01.tmpl")
  vars = {
    region                = var.region
    hostname              = "${var.region}-webserver-01"
  }
}

data "template_file" "user_data_nginx-02" {
  template = file("${path.module}/etc/ubuntu/ubuntu-02.tmpl")
  vars = {
    region                = var.region
    hostname              = "${var.region}-webserver-02"
  }
}

resource "aws_instance" "xC-mcn-site-ubuntu-01" {
  ami               = var.ubuntu_ami
  instance_type     = "t2.xlarge"
  availability_zone = "${var.region}a"
  key_name          = aws_key_pair.generated_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-site-ubuntu-01-public.id
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
 
  user_data = data.template_file.user_data_nginx-01.rendered 

  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-01"
  }
}

resource "aws_instance" "xC-mcn-site-ubuntu-02" {
  ami               = var.ubuntu_ami
  instance_type     = "t2.xlarge"
  availability_zone = "${var.region}a"
  key_name          = aws_key_pair.generated_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-site-ubuntu-02-public.id
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
 
  user_data = data.template_file.user_data_nginx-02.rendered 

  tags = {
    Name  = "${var.student}-xC-mcn-ubuntu-02"
  }
}