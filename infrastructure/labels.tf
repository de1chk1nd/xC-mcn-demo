resource "volterra_known_label_key" "xC-mcn-de1chk1nd" {
  key         = "de1chk1nd-mcn-sites"
  namespace   = "shared"
  description = "description"
}

resource "volterra_known_label" "vk8s_sites" {
  key         = "de1chk1nd-mcn-sites"
  namespace   = "shared"
  value       = "vk8s"
  description = "Used for vk8s sites"
  depends_on  = [volterra_known_label_key.xC-mcn-de1chk1nd]
}

resource "volterra_known_label" "sitemesh_sites" {
  key         = "de1chk1nd-mcn-sites"
  namespace   = "shared"
  value       = "sitemesh"
  description = "Used for vk8s sites"
  depends_on  = [volterra_known_label_key.xC-mcn-de1chk1nd]
}