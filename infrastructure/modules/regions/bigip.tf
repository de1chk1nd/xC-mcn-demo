resource "random_id" "id" {
  byte_length = 2
}

resource "aws_secretsmanager_secret" "bigip" {
  name = format("%s-bigip-secret-%s", var.student, random_id.id.hex)
  tags = {
    Name = "${var.student}-bigip-secret"

  }
}

resource "aws_secretsmanager_secret_version" "bigip-pwd" {
  secret_id     = aws_secretsmanager_secret.bigip.id
  secret_string = var.f5_password
}

resource "aws_network_interface" "mgmt" {
  subnet_id         = aws_subnet.xC-mcn-site-bigip-mgmt.id
  security_groups   = [aws_security_group.xC-mcn-site-allow-bigip-mgmt.id]
  private_ips_count = 1
  tags = {
    "Name" = "${var.student}-nic-bigip-mgmt"
  }
}

data "aws_network_interface" "bigip-mgmt" {
  id = aws_network_interface.mgmt.id
}

resource "aws_network_interface" "external" {
  subnet_id         = aws_subnet.xC-mcn-site-subnet.id
  security_groups   = [aws_security_group.xC-mcn-site-allow-bigip.id]
  private_ips_count = 4
  tags = {
    "Name" = "${var.student}-nic-bigip-external"
  }
}

data "aws_network_interface" "bigip-external" {
  id = aws_network_interface.external.id
}

resource "aws_network_interface" "internal" {
  subnet_id         = aws_subnet.xC-mcn-site-subnet-priv.id
  security_groups   = [aws_security_group.xC-mcn-site-allow-bigip.id]
  private_ips_count = 4
  tags = {
    "Name" = "${var.student}-nic-bigip-internal"
  }
}

data "aws_network_interface" "bigip-internal" {
  id = aws_network_interface.internal.id
}

resource "aws_eip" "bigip-mgmt" {
  network_interface = aws_network_interface.mgmt.id
  tags = {
    Name  = "${var.student}-bigip-mgmt"
    Owner = var.owner
  }
}
resource "aws_eip" "bigip-ext-0" {
  network_interface         = aws_network_interface.external.id
  associate_with_private_ip = data.aws_network_interface.bigip-external.private_ips[0]
  tags = {
    Name  = "${var.student}-bigip-external-0"
    Owner = var.owner
  }
}
resource "aws_eip" "bigip-ext-1" {
  network_interface         = aws_network_interface.external.id
  associate_with_private_ip = data.aws_network_interface.bigip-external.private_ips[1]
  tags = {
    Name  = "${var.student}-bigip-external-1"
    Owner = var.owner
  }
}
resource "aws_eip" "bigip-ext-2" {
  network_interface         = aws_network_interface.external.id
  associate_with_private_ip = data.aws_network_interface.bigip-external.private_ips[2]
  tags = {
    Name  = "${var.student}-bigip-external-2"
    Owner = var.owner
  }
}
resource "aws_eip" "bigip-ext-3" {
  network_interface         = aws_network_interface.external.id
  associate_with_private_ip = data.aws_network_interface.bigip-external.private_ips[3]
  tags = {
    Name = "${var.student}-bigip-external-3"
  }
}
resource "aws_eip" "bigip-ext-4" {
  network_interface         = aws_network_interface.external.id
  associate_with_private_ip = data.aws_network_interface.bigip-external.private_ips[4]
  tags = {
    Name = "${var.student}-bigip-external-4"
  }
}

resource "aws_instance" "f5_bigip" {
  instance_type = "m5n.2xlarge"
  ami           = var.f5_ami
  key_name      = aws_key_pair.generated_key.key_name
  monitoring    = true
  user_data = templatefile("${path.module}/etc/bigip/user-data.tmpl", {
    bigip_username         = "admin"
    ssh_keypair            = aws_key_pair.generated_key.key_name
    aws_secretmanager_auth = aws_secretsmanager_secret.bigip.id
    bigip_password         = var.f5_password
    student                = var.student
    student_ip             = var.student_ip
    mgmtip                 = aws_network_interface.mgmt.private_ip
    externalip             = data.aws_network_interface.bigip-external.private_ips[0]
    pIP_1                  = data.aws_network_interface.bigip-external.private_ips[1]
    pIP_2                  = data.aws_network_interface.bigip-external.private_ips[2]
    pIP_3                  = data.aws_network_interface.bigip-external.private_ips[3]
    pIP_4                  = data.aws_network_interface.bigip-external.private_ips[4]
    internalip             = data.aws_network_interface.bigip-internal.private_ips[0]
    iIP_1                  = data.aws_network_interface.bigip-internal.private_ips[1]
    iIP_2                  = data.aws_network_interface.bigip-internal.private_ips[2]
    iIP_3                  = data.aws_network_interface.bigip-internal.private_ips[3]
    iIP_4                  = data.aws_network_interface.bigip-internal.private_ips[4]
    domain_suffix          = local.domain_suffix
    INIT_URL               = var.INIT_URL
    DO_URL                 = var.DO_URL
    DO_VER                 = split("/", var.DO_URL)[7]
    AS3_URL                = var.AS3_URL
    AS3_VER                = split("/", var.AS3_URL)[7]
    TS_VER                 = split("/", var.TS_URL)[7]
    TS_URL                 = var.TS_URL
    CFE_URL                = var.CFE_URL
    CFE_VER                = split("/", var.CFE_URL)[7]
  })

  root_block_device {
    delete_on_termination = true
  }

  network_interface {
    network_interface_id = aws_network_interface.mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.external.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.internal.id
    device_index         = 2
  }

  depends_on = [aws_eip.bigip-mgmt, aws_eip.bigip-ext-0]

  tags = {
    Name = "${var.student}-bigip"
  }
}