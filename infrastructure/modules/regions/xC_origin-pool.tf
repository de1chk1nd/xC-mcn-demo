resource "volterra_origin_pool" "local-webserver" {
  name                   = "origin-aws-web-${var.region}"
  namespace              = "m-petersen"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    private_name {
      dns_name = "web.de1chk1nd-mcn.aws"
      site_locator {
        site {
          tenant = "f5-emea-ent-bceuutam"
          namespace = "system"
          name = local.smsv2-site-name
          }
        }
      outside_network = true
      }
    }

  healthcheck {
    tenant = "f5-emea-ent-bceuutam"
    namespace = "m-petersen"
    name = "hello-check"
  }

  port = "80"
  no_tls = true

  depends_on = [
    volterra_securemesh_site_v2.xC-mcn-smsv2-appstack
  ]
}