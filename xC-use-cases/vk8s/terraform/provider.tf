provider "volterra" {
  api_p12_file = "/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.xC/f5-emea-ent.console.ves.volterra.io.api-creds.p12"
  url          = local.setup-init.xC.tenant_api
}

terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
    }
    null = {
      source = "hashicorp/null"
    }
    local = {
      source = "hashicorp/local"
    }
    volterra = {
      source = "volterraedge/volterra"
    }
  }
}