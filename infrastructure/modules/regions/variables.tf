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

variable "smsv2_ami" {
  description = "linux server ami"
  type        = string
}

variable "f5_ami" {
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

variable "f5_password" {
  description = "Owner for resources created by this module"
  type        = string
  default     = "REDACTED_P12_PASSWORD"
}


#F5 Automation Toolchain
variable "DO_URL"            { default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.35.0/f5-declarative-onboarding-1.35.0-6.noarch.rpm" }
variable "AS3_URL"           { default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v.3.42.0/f5-appsvcs-3.42.0-5.noarch.rpm" }
variable "TS_URL"            { default = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.32.0/f5-telemetry-1.32.0-2.noarch.rpm" }
variable "CFE_URL"           { default = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.13.0/f5-cloud-failover-1.13.0-0.noarch.rpm" }
variable "INIT_URL"          { default = "https://github.com/F5Networks/f5-bigip-runtime-init/releases/download/1.5.2/f5-bigip-runtime-init-1.5.2-1.gz.run" }