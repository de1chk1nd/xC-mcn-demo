variable "auth_profile" {
  description = "linux server ami"
  type        = string
}

variable "region" {
  description = "linux server ami"
  type        = string
}

variable "vpc_cidr" {
  description = "BIG-IP AMI name to search for"
  type        = string
}

variable "subnet_cidr" {
  description = "BIG-IP AMI name to search for"
  type        = string
}

variable "ubuntu_ami" {
  description = "linux server ami"
  type        = string
}

variable "public_key" {
  description = "linux server ami"
  type        = string
}

variable "owner" {
  description = "Owner for resources created by this module"
  type        = string
  default     = "terraform-aws-bigip-demo"
}

variable "student" {
  description = "Owner for resources created by this module"
  type        = string
  default     = "terraform-aws-bigip-demo"
}

variable "student_ip" {
  description = "Owner for resources created by this module"
  type        = string
  default     = "terraform-aws-bigip-demo"
}

variable "remote_cidr" {
  description = "Owner for resources created by this module"
  type        = string
}