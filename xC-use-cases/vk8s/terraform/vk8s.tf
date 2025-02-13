resource "volterra_virtual_k8s" "example" {
  name      = "de1chk1nd-vk8s"
  namespace = "m-petersen"

  vsite_refs {
   name = "de1chk1nd-vk8s-sites"
   namespace = "sytem"
  }
}