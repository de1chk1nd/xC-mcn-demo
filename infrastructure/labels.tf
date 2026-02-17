resource "volterra_known_label_key" "xC-mcn-student-sites" {
  key         = "${local.setup-init.student.name}-mcn-sites"
  namespace   = "shared"
  description = "description"
}

resource "volterra_known_label" "vk8s_sites" {
  key         = "${local.setup-init.student.name}-mcn-sites"
  namespace   = "shared"
  value       = "vk8s"
  description = "Used for vk8s sites"
  depends_on  = [volterra_known_label_key.xC-mcn-student-sites]
}

resource "volterra_known_label" "eu-central_sites" {
  key         = "${local.setup-init.student.name}-mcn-sites"
  namespace   = "shared"
  value       = "eu-central"
  description = "Used for eu-central sites"
  depends_on  = [volterra_known_label_key.xC-mcn-student-sites]
}

resource "volterra_known_label" "eu-west_sites" {
  key         = "${local.setup-init.student.name}-mcn-sites"
  namespace   = "shared"
  value       = "eu-west"
  description = "Used for eu-west sites"
  depends_on  = [volterra_known_label_key.xC-mcn-student-sites]
}