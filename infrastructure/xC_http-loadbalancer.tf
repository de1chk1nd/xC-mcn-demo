resource "volterra_http_loadbalancer" "host-rewrite" {
  name      = "http-lb-host-rewrite"
  namespace = "m-petersen"

  domains = ["*.de1chk1nd.eu"]

  http {
    dns_volterra_managed = false
    port                 = "80"
  }

  routes {
    simple_route {
      path {
        prefix = "/"
      }
      headers {
        name  = "Host"
        exact = "app-1.de1chk1nd.eu"
      }

      origin_pools {
        pool {
          name      = "origin-aws-web-eu-central-1"
          namespace = "m-petersen"
        }
      }
      host_rewrite = "app-1.m-petersen.eu"
    }
  }

  depends_on = [
    module.eu-central-1,
    module.eu-west-1
  ]

}