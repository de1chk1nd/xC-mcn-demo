module "eu-central-1" {
  source = "./modules/regions"

  region       = local.setup-init.aws.region_site_1
  auth_profile = local.setup-init.aws.auth_profile

  # Main VPC
  vpc_cidr         = "10.0.0.0/16"
  subnet_cidr_pub  = "10.0.0.0/24"
  subnet_cidr_priv = "10.0.20.0/24"
  subnet_cidr_mgmt = "10.0.100.0/24"
  subnet_cidr_tran = "10.0.200.0/24"
  # App VPC
  vpc_cidr_app    = "192.168.0.0/17"
  subnet_cidr_app = "192.168.0.0/24"

  ubuntu_ami  = lookup(var.ubuntu_ami, local.setup-init.aws.region_site_1)
  smsv2_ami   = lookup(var.smsv2_ami, local.setup-init.aws.region_site_1)
  f5_ami      = lookup(var.f5_ami, local.setup-init.aws.region_site_1)
  remote_cidr = "172.16.0.0/16"

  public_key = tls_private_key.ssh_key_access.public_key_openssh

  owner      = local.setup-init.student.email
  student    = local.setup-init.student.name
  student_ip = local.setup-init.student.ip-address
  f5_password = local.setup-init.f5.f5_password

  vsite_k8s    = volterra_virtual_site.vk8s_sites.name
  vsite_conf   = volterra_virtual_site.eu-central_sites.name
  vsite-region = "eu-central"

}

module "eu-west-1" {
  source = "./modules/regions"

  region       = local.setup-init.aws.region_site_2
  auth_profile = local.setup-init.aws.auth_profile

  # Main VPC
  vpc_cidr         = "172.16.0.0/16"
  subnet_cidr_pub  = "172.16.0.0/24"
  subnet_cidr_priv = "172.16.20.0/24"
  subnet_cidr_mgmt = "172.16.100.0/24"
  subnet_cidr_tran = "172.16.200.0/24"
  # App VPC
  vpc_cidr_app    = "192.168.128.0/17"
  subnet_cidr_app = "192.168.128.0/24"

  ubuntu_ami  = lookup(var.ubuntu_ami, local.setup-init.aws.region_site_2)
  smsv2_ami   = lookup(var.smsv2_ami, local.setup-init.aws.region_site_2)
  f5_ami      = lookup(var.f5_ami, local.setup-init.aws.region_site_2)
  remote_cidr = "10.0.0.0/16"

  public_key = tls_private_key.ssh_key_access.public_key_openssh

  owner      = local.setup-init.student.email
  student    = local.setup-init.student.name
  student_ip = local.setup-init.student.ip-address
  f5_password = local.setup-init.f5.f5_password


  vsite_k8s    = volterra_virtual_site.vk8s_sites.name
  vsite_conf   = volterra_virtual_site.eu-west_sites.name
  vsite-region = "eu-west"

}