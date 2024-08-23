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
          name = volterra_aws_vpc_site.xC-mcn-appstack.name
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
    volterra_tf_params_action.action_apply
  ]
}