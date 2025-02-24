resource "random_id" "xC-mcn-eu-central-1-id" {
  byte_length = 2
}

locals {
  smsv2-site-name = "${var.student}-${random_id.xC-mcn-eu-central-1-id.hex}-aws-${var.region}"
}

resource "volterra_securemesh_site_v2" "xC-mcn-smsv2-appstack" {
  name      = local.smsv2-site-name
  namespace = "system"

  block_all_services      = true
  logs_streaming_disabled = true
  enable_ha               = false

  labels = {
    "ves.io/provider"                  = "ves-io-AWS"
    "de1chk1nd-mcn-sites"              = "vk8s"
  }

  re_select {
    geo_proximity = true
  }

  aws {
    not_managed {}
  }

  lifecycle {
    ignore_changes = [
      labels
    ]
  }

}

resource "volterra_token" "xC-mcn-sitetoken" {
  name      = "token-${random_id.xC-mcn-eu-central-1-id.hex}"
  namespace = "system"
  type = "1"
  site_name = local.smsv2-site-name
  depends_on = [ 
    volterra_securemesh_site_v2.xC-mcn-smsv2-appstack
    ]
}

resource "aws_network_interface" "xC-mcn-slo-v2" {
  description = "SLo"
  subnet_id       = aws_subnet.xC-mcn-site-subnet.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id, 
    aws_security_group.xC-mcn-site-ce-to-americas.id, 
    aws_security_group.xC-mcn-site-ce-to-europe.id, 
    aws_security_group.xC-mcn-site-ce-to-asia.id
  ]
  tags = {
    Name = "f5-ce-SLo"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-priv" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-SLi"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-priv-bigip" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-bigip-mgmt.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-SLi-bigip-mgmt"
  }
}

resource "aws_eip" "xC-mcn-site-ubuntu-eip-v2" {
  network_interface = aws_network_interface.xC-mcn-slo-v2.id
  
  depends_on = [
    aws_network_interface.xC-mcn-slo-v2,
    aws_instance.xC-mcn-ce-v2
  ]

  tags = {
    Name = "f5-ce-pip"
  }
}

data "template_file" "user_data_smsv2" {
  template = file("${path.module}/etc/smsv2/user-data.tmpl")
  vars = {
    token                = volterra_token.xC-mcn-sitetoken.id
  }
}

resource "aws_instance" "xC-mcn-ce-v2" {
  ami                  = var.smsv2_ami
  key_name             = aws_key_pair.generated_key.key_name
  monitoring           = false
  instance_type        = "t3.2xlarge"
  user_data            = data.template_file.user_data_smsv2.rendered

  root_block_device {
    volume_size = 120
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-slo-v2.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv.id
  }

  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv-bigip.id
  }

  timeouts {
    create = "60m"
    update = "30m"
    delete = "60m"
  }

  tags = {
    "Name"                                           = "f5-ce-${local.smsv2-site-name}"
    "ves-io-site-name"                               = local.smsv2-site-name
    "kubernetes.io/cluster/${local.smsv2-site-name}" = "owned"
  }

}