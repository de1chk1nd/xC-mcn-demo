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
    # "de1chk1nd-vk8s-sites"             = "basic-demo"
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
  security_groups = [aws_security_group.xC-mcn-site-allow-ubuntu.id]
  tags = {
    Name = "f5-ce-SLo"
  }
}

resource "aws_network_interface" "xC-mcn-slo-v2-priv" {
  description = "SLi"
  subnet_id       = aws_subnet.xC-mcn-site-subnet-priv.id
  source_dest_check = false
  security_groups = [aws_security_group.xC-mcn-site-allow-ubuntu.id]
  tags = {
    Name = "f5-ce-SLi"
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
    volume_size = 80
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.xC-mcn-slo-v2.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.xC-mcn-slo-v2-priv.id
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

# resource "volterra_aws_vpc_site" "xC-mcn-appstack" {
#   name       = "${var.student}-${random_id.xC-mcn-eu-central-1-id.hex}-aws-${var.region}"
#   namespace  = "system"
#   aws_region = "${var.region}"
#   ssh_key = aws_key_pair.generated_key.public_key
#   vpc {
#     vpc_id = aws_vpc.xC-mcn-site.id
#   }
#   voltstack_cluster {
#     aws_certified_hw = "aws-byol-voltstack-combo"
#     az_nodes {
#       aws_az_name = "${var.region}a"
#       local_subnet {
#         existing_subnet_id = aws_subnet.xC-mcn-site-subnet.id
#       }
#     }
#     global_network_list {
#       global_network_connections {
#         slo_to_global_dr {
#           global_vn {
#             name      = "de1chk1nd-global"
#             namespace = "system"
#             tenant    = "f5-emea-ent-bceuutam"
#           }
#         }
#       }
#     }
#     no_network_policy        = true
#     no_forward_proxy         = true
#     no_outside_static_routes = true
#     no_global_network        = true
#     no_dc_cluster_group      = true
#     sm_connection_public_ip  = true
#     default_storage          = true
#     allowed_vip_port {
#       use_http_https_port = true
#     }
#     no_k8s_cluster = true
#   }
#   aws_cred {
#     name      = "de1chk1nd-aws-cee"
#     namespace = "system"
#     tenant    = "f5-emea-ent-bceuutam"
#   }
#   direct_connect_disabled  = true
#   instance_type            = "m5.4xlarge"
#   logs_streaming_disabled  = true
#   f5_orchestrated_routing  = false
#   manual_routing           = true
#   no_worker_nodes          = true
#   default_blocked_services = true
# 
#   depends_on = [
#     aws_route_table.xC-mcn-site-routetable
#     ]
# 
#   tags = {
#     Name = "${var.student}-xC"
#   }
# }
# 
# resource "volterra_tf_params_action" "action_apply" {
#   site_name       = volterra_aws_vpc_site.xC-mcn-appstack.name
#   site_kind       = "aws_vpc_site"
#   action          = "apply"
#   wait_for_action = true
# # 
# #   depends_on = [
# #     volterra_aws_vpc_site.xC-mcn-appstack
# #     ]
# # 
# # }
# 
# data "aws_instance" "xc_node" {
#   instance_tags = {
#     "ves-io-site-name" = local.smsv2-site-name
#   }
# 
#   filter {
# 	name   = "subnet-id"
# 	values = [aws_subnet.xC-mcn-site-subnet.id]
#   }
# 
#   depends_on = [
#     volterra_securemesh_site_v2.xC-mcn-smsv2-appstack
#   ]
# }
# 
# data "aws_network_interface" "xc_private_nic" {
#   filter {
# 	name   = "attachment.instance-id"
# 	values = [data.aws_instance.xc_node.id]
#   }
# 
#   filter {
# 	name   = "subnet-id"
# 	values = [aws_subnet.xC-mcn-site-subnet.id]
#   }
# 
#   depends_on = [
#     volterra_securemesh_site_v2.xC-mcn-smsv2-appstack
#   ]
# }

resource "aws_route" "remote_network" {
  route_table_id              = aws_route_table.xC-mcn-site-routetable.id
  destination_cidr_block      = var.remote_cidr
  network_interface_id        = aws_network_interface.xC-mcn-slo-v2.id

  depends_on = [
    aws_network_interface.xC-mcn-slo-v2
  ]

}