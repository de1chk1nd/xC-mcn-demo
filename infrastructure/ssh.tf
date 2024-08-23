resource "tls_private_key" "ssh_key_access" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key_access.private_key_pem
  filename        = "../setup-init/.ssh/${local.setup-init.student.name}-ssh.pem"
  file_permission = "0700"
} 