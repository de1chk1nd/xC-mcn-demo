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