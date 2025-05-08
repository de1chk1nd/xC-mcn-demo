resource "volterra_virtual_site" "vk8s_sites" {
  name      = "de1chk1nd-vk8s-sites"
  namespace = "shared"

  site_selector {
    expressions = ["de1chk1nd-mcn-sites in (vk8s)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.vk8s_sites
  ]
}

resource "volterra_virtual_site" "eu-central_sites" {
  name      = "de1chk1nd-eu-central-sites"
  namespace = "shared"

  site_selector {
    expressions = ["de1chk1nd-mcn-sites in (eu-central)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.eu-central_sites
  ]
}

resource "volterra_virtual_site" "eu-west_sites" {
  name      = "de1chk1nd-eu-west-sites"
  namespace = "shared"

  site_selector {
    expressions = ["de1chk1nd-mcn-sites in (eu-west)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [
    volterra_known_label.eu-west_sites
  ]
}