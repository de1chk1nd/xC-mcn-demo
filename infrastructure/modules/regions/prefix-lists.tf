resource "aws_ec2_managed_prefix_list" "xc-was-ips" {
  name         = "example-prefix-list"
  max_entries  = 5
  address_family = "IPv4"

  entry {
    cidr        = "34.140.183.146/32"
  }
}
# Americas Region Prefix List
resource "aws_ec2_managed_prefix_list" "xC_americas" {
  name           = "f5-americas-edge"
  address_family = "IPv4"
  max_entries    = 11

  entry {
    cidr        = "185.94.142.0/25"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "185.94.143.0/25"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "159.60.190.0/24"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "159.60.168.0/24"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "159.60.180.0/24"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "159.60.174.0/24"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "159.60.176.0/24"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "5.182.215.0/25"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "84.54.61.0/25"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "23.158.32.0/25"
    description = "F5 Americas Edge"
  }
  entry {
    cidr        = "84.54.62.0/25"
    description = "F5 Americas Edge"
  }
}

# Europe Region Prefix List
resource "aws_ec2_managed_prefix_list" "xC_europe" {
  name           = "f5-europe-edge"
  address_family = "IPv4"
  max_entries    = 11

  entry {
    cidr        = "5.182.213.0/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "5.182.212.0/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "5.182.213.128/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "5.182.214.0/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "84.54.60.0/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "185.56.154.0/25"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "159.60.160.0/24"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "159.60.162.0/24"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "159.60.188.0/24"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "159.60.182.0/24"
    description = "F5 Europe Edge"
  }
  entry {
    cidr        = "159.60.178.0/24"
    description = "F5 Europe Edge"
  }
}

# Asia Region Prefix List
resource "aws_ec2_managed_prefix_list" "xC_asia" {
  name           = "f5-asia-edge"
  address_family = "IPv4"
  max_entries    = 14

  entry {
    cidr        = "103.135.56.0/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.184.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.186.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "103.135.57.0/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "103.135.56.128/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "103.135.59.0/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "103.135.58.128/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "103.135.58.0/25"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.189.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.166.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.164.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.170.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.172.0/24"
    description = "F5 Asia Edge"
  }
  entry {
    cidr        = "159.60.191.0/24"
    description = "F5 Asia Edge"
  }
}