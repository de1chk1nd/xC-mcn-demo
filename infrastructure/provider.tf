provider "volterra" {
  api_p12_file = "../setup-init/${local.setup-init.xC.p12_auth}"
  url          = local.setup-init.xC.tenant_api
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~>5.0"
    }
    random = {
      source = "hashicorp/random"
      #version = "~>3.0"
    }
    null = {
      source = "hashicorp/null"
      #version = "~>3.0"
    }
    local = {
      source = "hashicorp/local"
      #version = "~>2.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = ">= 0.11.42"
    }
  }
}