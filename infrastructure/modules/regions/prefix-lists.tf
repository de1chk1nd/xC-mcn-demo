resource "aws_ec2_managed_prefix_list" "xc-was-ips" {
  name         = "example-prefix-list"
  max_entries  = 5
  address_family = "IPv4"

  entry {
    cidr        = "34.140.183.146/32"
    description = "Allowed IP 1"
  }

  entry {
    cidr        = "35.241.176.167/32"
    description = "Allowed IP 2"
  }

  entry {
    cidr        = "34.77.66.77/32"
    description = "Allowed IP 3"
  }

  entry {
    cidr        = "34.140.250.140/32"
    description = "Allowed IP 4"
  }

  entry {
    cidr        = "34.22.187.249/32"
    description = "Allowed IP 5"
  }
}