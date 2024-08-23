provider "volterra" {
  api_p12_file = local.setup-init.xC.p12_auth
  url          = local.setup-init.xC.tenant_api
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~>2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = "~>0.11"
    }
  }
}