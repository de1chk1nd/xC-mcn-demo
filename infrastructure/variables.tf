locals {
  setup-init = yamldecode(file("../setup-init/config.yaml"))
  nginx_key  = "${path.cwd}/setup-init/.nginx/lic-plus/nginx-repo.key"
  nginx_cer  = "${path.cwd}/setup-init/.nginx/lic-plus/nginx-repo.crt"
  ssh_key    = "${path.cwd}/setup-init/.ssh/${local.setup-init.student.name}-ssh.pem"

}

# AMI Slection
variable "ubuntu_ami" {
  type = map(any)
  default = {
    eu-central-1 = "ami-0b81e95bb0a06ea8c" # r.20221212
    eu-west-1    = "ami-029cfca952b331b52" # r.20221212
  }
}
# https://cloud-images.ubuntu.com/locator/ec2/