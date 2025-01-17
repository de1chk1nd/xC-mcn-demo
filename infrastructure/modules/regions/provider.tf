provider "aws" {
  profile = var.auth_profile
  region  = var.region

  default_tags {
    tags = {
      Owner = var.owner
    }

  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~>4.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      # version = "~>0.11"
    }
  }
}