resource "random_id" "xC-mcn-eu-central-1-id" {
  byte_length = 2
}
resource "volterra_aws_vpc_site" "xC-mcn-appstack" {
  name       = "${var.student}-aws-${random_id.xC-mcn-eu-central-1-id.hex}"
  namespace  = "system"
  aws_region = "${var.region}"
  ssh_key = aws_key_pair.generated_key.public_key
  vpc {
    vpc_id = aws_vpc.xC-mcn-site.id
  }
  voltstack_cluster {
    aws_certified_hw = "aws-byol-voltstack-combo"
    az_nodes {
      aws_az_name = "${var.region}a"
      local_subnet {
        existing_subnet_id = aws_subnet.xC-mcn-site-subnet.id
      }
    }
    global_network_list {
      global_network_connections {
        slo_to_global_dr {
          global_vn {
            name      = "de1chk1nd-global"
            namespace = "system"
            tenant    = "f5-emea-ent-bceuutam"
          }
        }
      }
    }
    no_network_policy        = true
    no_forward_proxy         = true
    no_outside_static_routes = true
    no_global_network        = true
    no_dc_cluster_group      = true
    sm_connection_public_ip  = true
    default_storage          = true
    allowed_vip_port {
      use_http_https_port = true
    }
    no_k8s_cluster = true
  }
  aws_cred {
    name      = "de1chk1nd-aws-cee"
    namespace = "system"
    tenant    = "f5-emea-ent-bceuutam"
  }
  direct_connect_disabled  = true
  instance_type            = "m5.4xlarge"
  logs_streaming_disabled  = true
  no_worker_nodes          = true
  default_blocked_services = true

  depends_on = [
    aws_route_table.xC-mcn-site-routetable
    ]

  tags = {
    Name = "${var.student}-xC"
  }
}

resource "volterra_tf_params_action" "action_apply" {
  site_name       = volterra_aws_vpc_site.xC-mcn-appstack.name
  site_kind       = "aws_vpc_site"
  action          = "apply"
  wait_for_action = true

  depends_on = [
    volterra_aws_vpc_site.xC-mcn-appstack
    ]

}

data "aws_instance" "xc_node" {
  instance_tags = {
    "ves-io-site-name" = volterra_aws_vpc_site.xC-mcn-appstack.name
  }

  filter {
	name   = "subnet-id"
	values = [aws_subnet.xC-mcn-site-subnet.id]
  }

  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

data "aws_network_interface" "xc_private_nic" {
  filter {
	name   = "attachment.instance-id"
	values = [data.aws_instance.xc_node.id]
  }

  filter {
	name   = "subnet-id"
	values = [aws_subnet.xC-mcn-site-subnet.id]
  }

  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

resource "aws_route" "remote_network" {
  route_table_id              = aws_route_table.xC-mcn-site-routetable.id
  destination_cidr_block      = var.remote_cidr
  network_interface_id        = data.aws_network_interface.xc_private_nic.id

  depends_on = [
    data.aws_network_interface.xc_private_nic
  ]

}