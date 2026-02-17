resource "volterra_virtual_site" "vk8s_sites" {
  name      = "${local.setup-init.student.name}-vk8s-sites"
  namespace = "shared"

  site_selector {
    expressions = ["${local.setup-init.student.name}-mcn-sites in (vk8s)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.vk8s_sites
  ]
}

resource "volterra_virtual_site" "eu-central_sites" {
  name      = "${local.setup-init.student.name}-eu-central-sites"
  namespace = "shared"

  site_selector {
    expressions = ["${local.setup-init.student.name}-mcn-sites in (eu-central)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.eu-central_sites
  ]
}

resource "volterra_virtual_site" "eu-west_sites" {
  name      = "${local.setup-init.student.name}-eu-west-sites"
  namespace = "shared"

  site_selector {
    expressions = ["${local.setup-init.student.name}-mcn-sites in (eu-west)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.eu-west_sites
  ]
}