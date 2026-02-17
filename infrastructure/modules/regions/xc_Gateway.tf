### Prepare Installation - set names
###

resource "random_id" "xC-mcn-eu-central-1-id" {
  byte_length = 2
}

locals {
  smsv2-site-name-gw01 = "${var.student}-${random_id.xC-mcn-eu-central-1-id.hex}-aws-${var.region}-01"
  smsv2-site-name-gw02 = "${var.student}-${random_id.xC-mcn-eu-central-1-id.hex}-aws-${var.region}-02"
}

### Configure Gateways in xC Console (GW01 and GW02) and Generate Tokens
###

resource "volterra_securemesh_site_v2" "xC-mcn-smsv2-appstack-01" {
  name      = local.smsv2-site-name-gw01
  namespace = "system"

  block_all_services      = true
  logs_streaming_disabled = true
  enable_ha               = false

  labels = {
    "ves.io/provider"                       = "ves-io-AWS"
    "${var.student}-mcn-sites"              = "vk8s"
    "${var.student}-mcn-sites"              = "${var.vsite-region}"
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

resource "volterra_securemesh_site_v2" "xC-mcn-smsv2-appstack-02" {
  name      = local.smsv2-site-name-gw02
  namespace = "system"

  block_all_services      = true
  logs_streaming_disabled = true
  enable_ha               = false

  labels = {
    "ves.io/provider"                       = "ves-io-AWS"
    "${var.student}-mcn-sites"              = "vk8s"
    "${var.student}-mcn-sites"              = "${var.vsite-region}"
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

resource "volterra_token" "xC-mcn-sitetoken-01" {
  name      = "token-${random_id.xC-mcn-eu-central-1-id.hex}-gw01"
  namespace = "system"
  type = "1"
  site_name = local.smsv2-site-name-gw01
  depends_on = [ 
    volterra_securemesh_site_v2.xC-mcn-smsv2-appstack-01
    ]
}

resource "volterra_token" "xC-mcn-sitetoken-02" {
  name      = "token-${random_id.xC-mcn-eu-central-1-id.hex}-gw02"
  namespace = "system"
  type = "1"
  site_name = local.smsv2-site-name-gw02
  depends_on = [ 
    volterra_securemesh_site_v2.xC-mcn-smsv2-appstack-02
    ]
}

### Create NICs, EIPs, User-Data, ...
###

resource "aws_network_interface" "xC-mcn-slo-v2-publ-01" {
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
    Name = "f5-ce-SLo-gw01"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-priv-01" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-SLi-gw01"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-tran-01" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-transfer-tgw.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-segment-tgw-gw01"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-publ-02" {
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
    Name = "f5-ce-SLo-gw02"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-priv-02" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-SLi-gw02"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-tran-02" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-transfer-tgw.id
  source_dest_check = false
  security_groups = [
    aws_security_group.xC-mcn-site-ce-access-generic.id
  ]
  tags = {
    Name = "f5-ce-segment-tgw-gw02"
  }
}

resource "aws_eip" "xC-mcn-slo-v2-eip-01" {
  network_interface = aws_network_interface.xC-mcn-slo-v2-publ-01.id
  
  depends_on = [
    aws_network_interface.xC-mcn-slo-v2-publ-01,
    aws_instance.xC-mcn-ce-v2-01
  ]

  tags = {
    Name = "f5-ce-pip-gw01"
  }
}

resource "aws_eip" "xC-mcn-slo-v2-eip-02" {
  network_interface = aws_network_interface.xC-mcn-slo-v2-publ-02.id
  
  depends_on = [
    aws_network_interface.xC-mcn-slo-v2-publ-02,
    aws_instance.xC-mcn-ce-v2-01
  ]

  tags = {
    Name = "f5-ce-pip-gw02"
  }
}

data "template_file" "user_data_smsv2-01" {
  template = file("${path.module}/etc/smsv2/user-data.tmpl")
  vars = {
    token                = volterra_token.xC-mcn-sitetoken-01.id
  }
}

data "template_file" "user_data_smsv2-02" {
  template = file("${path.module}/etc/smsv2/user-data.tmpl")
  vars = {
    token                = volterra_token.xC-mcn-sitetoken-02.id
  }
}

### AWS Instances
###

resource "aws_instance" "xC-mcn-ce-v2-01" {
  ami                  = var.smsv2_ami
  key_name             = aws_key_pair.generated_key.key_name
  monitoring           = false
  instance_type        = "m5.2xlarge"
  user_data            = data.template_file.user_data_smsv2-01.rendered

  root_block_device {
    volume_size = 120
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-publ-01.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv-01.id
  }

  # network_interface {
  #   device_index         = 2
  #   network_interface_id = aws_network_interface.xC-mcn-slo-v2-tran-01.id
  # }

  timeouts {
    create = "60m"
    update = "30m"
    delete = "60m"
  }

  tags = {
    "Name"                                                = "f5-ce-${local.smsv2-site-name-gw01}"
    "ves-io-site-name"                                    = local.smsv2-site-name-gw01
    "kubernetes.io/cluster/${local.smsv2-site-name-gw01}" = "owned"
  }

}

resource "aws_instance" "xC-mcn-ce-v2-02" {
  ami                  = var.smsv2_ami
  key_name             = aws_key_pair.generated_key.key_name
  monitoring           = false
  instance_type        = "m5.2xlarge"
  user_data            = data.template_file.user_data_smsv2-02.rendered

  root_block_device {
    volume_size = 120
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-publ-02.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv-02.id
  }

  # network_interface {
  #   device_index         = 2
  #   network_interface_id = aws_network_interface.xC-mcn-slo-v2-tran-02.id
  # }

  timeouts {
    create = "60m"
    update = "30m"
    delete = "60m"
  }

  tags = {
    "Name"                                                = "f5-ce-${local.smsv2-site-name-gw02}"
    "ves-io-site-name"                                    = local.smsv2-site-name-gw02
    "kubernetes.io/cluster/${local.smsv2-site-name-gw02}" = "owned"
  }

}