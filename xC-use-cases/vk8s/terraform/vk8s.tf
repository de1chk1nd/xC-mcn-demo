resource "volterra_virtual_k8s" "example" {
  name      = "${local.setup-init.student.name}-vk8s"
  namespace = local.setup-init.xC.namespace

  vsite_refs {
    name      = "${local.setup-init.student.name}-vk8s-sites"
    namespace = "shared"
  }
}