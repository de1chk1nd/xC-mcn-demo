# resource "volterra_virtual_site" "vk8s_sites" {
#  name      = "de1chk1nd-vk8s-sites"
#  namespace = "system"
# 
#  site_selector {
#    expressions = ["de1chk1nd-vk8s-sites in (basic-demo)"]
#  }
# 
#  site_type = "CE"
# 
#  depends_on = [
#    volterra_known_label.vk8s_sites
#  ]
# 