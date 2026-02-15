locals {
  setup-init = yamldecode(file("../setup-init/config.yaml"))
  nginx_key  = "${path.cwd}/setup-init/.nginx/lic-plus/nginx-repo.key"
  nginx_cer  = "${path.cwd}/setup-init/.nginx/lic-plus/nginx-repo.crt"
  ssh_key    = "${path.cwd}/setup-init/.ssh/${local.setup-init.student.name}-ssh.pem"

}

# AMI Selection - Ubuntu 24.04 LTS (Noble)
# Lookup: aws ec2 describe-images --profile terraform --region eu-central-1 --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" --output text
# Lookup: aws ec2 describe-images --profile terraform --region eu-west-1 --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" --output text
variable "ubuntu_ami" {
  type = map(any)
  default = {
    eu-central-1 = "ami-0aad10862ade98f27" # Ubuntu 24.04 Noble - run lookup command above
    eu-west-1    = "ami-092b91d47c6c8baa5" # Ubuntu 24.04 Noble - run lookup command above
  }
}

# https://cloud-images.ubuntu.com/locator/ec2/

# AMI Selection - smsv2
variable "smsv2_ami" {
  type = map(any)
  default = {
    eu-central-1 = "ami-09e2a64a4def5c3f4" # f5xc-ce-9.2024.44-20250102062607
    eu-west-1    = "ami-0b6745ec15401ac80" # f5xc-ce-9.2024.44-20250102062607
  }
}


variable "f5_ami" {
  type = map(any)
  default = {
    eu-central-1 = "ami-0330d966590bfc503" # f5xc-ce-9.2024.44-20250102062607
    eu-west-1    = "ami-09f63b948981ca9b0" # f5xc-ce-9.2024.44-20250102062607
  }
}
#aws ec2 describe-images --profile terraform --region eu-central-1 --owners '679593333241' --filters Name=description,Values='*BIGIP-17.1*PAYG*Best*25Mbps*' --query "Images[*].[Description, CreationDate, ImageId]"
#aws ec2 describe-images --profile terraform --region eu-west-1 --owners '679593333241' --filters Name=description,Values='*BIGIP-17.1*PAYG*Best*25Mbps*' --query "Images[*].[Description, CreationDate, ImageId]"
