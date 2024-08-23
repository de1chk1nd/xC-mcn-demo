module "eu-central-1" {
  source = "./modules/regions"

  region       = local.setup-init.aws.region_site_1
  auth_profile = local.setup-init.aws.auth_profile

  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.0.0/24"
  ubuntu_ami  = lookup(var.ubuntu_ami, local.setup-init.aws.region_site_1)
  remote_cidr = "10.10.0.0/16"

  public_key = tls_private_key.ssh_key_access.public_key_openssh

  owner      = local.setup-init.student.email
  student    = local.setup-init.student.name
  student_ip = local.setup-init.student.ip-address

}

module "eu-west-1" {
  source = "./modules/regions"

  region       = local.setup-init.aws.region_site_2
  auth_profile = local.setup-init.aws.auth_profile

  vpc_cidr    = "10.10.0.0/16"
  subnet_cidr = "10.10.0.0/24"
  ubuntu_ami  = lookup(var.ubuntu_ami, local.setup-init.aws.region_site_2)
  remote_cidr = "10.1.0.0/16"

  public_key = tls_private_key.ssh_key_access.public_key_openssh

  owner      = local.setup-init.student.email
  student    = local.setup-init.student.name
  student_ip = local.setup-init.student.ip-address

}