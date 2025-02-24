resource "aws_route53_zone" "private" {
  name = "de1chk1nd-mcn.aws"
  vpc {
    vpc_id = aws_vpc.xC-mcn-site.id
  }
  tags = {
    Name  = "${var.student}-xC-mcn-ig"
  }
}
 
resource "aws_route53_record" "local-web" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "web.de1chk1nd-mcn.aws"
  type    = "A"
  ttl     = "300"
  records = [aws_network_interface.xC-mcn-site-ubuntu-public.private_ip]

  depends_on = [
    aws_network_interface.xC-mcn-site-ubuntu-public
  ]

}

resource "aws_route53_record" "remote-web" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "remote-web.de1chk1nd-mcn.aws"
  type    = "A"
  ttl     = "300"
  records = [aws_network_interface.xC-mcn-slo-v2-priv.private_ip]

  depends_on = [
    aws_network_interface.xC-mcn-slo-v2
  ]

}

resource "aws_route53_record" "local-web-lb" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "local-web.de1chk1nd-mcn.aws"
  type    = "A"
  ttl     = "300"
  records = [aws_network_interface.xC-mcn-slo-v2-priv.private_ip]

  depends_on = [
    aws_network_interface.xC-mcn-slo-v2
  ]

}

resource "aws_route53_record" "bigip-web" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bigip-web.de1chk1nd-lab.aws"
  type    = "A"
  ttl     = "300"
  records = [data.aws_network_interface.bigip-internal.private_ips[0]]

  depends_on = [
    aws_network_interface.mgmt
  ]

}

resource "aws_route53_record" "bigip-echo" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bigip-echo.de1chk1nd-lab.aws"
  type    = "A"
  ttl     = "300"
  records = [data.aws_network_interface.bigip-internal.private_ips[2]]

  depends_on = [
    aws_network_interface.mgmt
  ]

}

resource "aws_route53_record" "bigip-echo-ssl" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bigip-echo-ssl.de1chk1nd-lab.aws"
  type    = "A"
  ttl     = "300"
  records = [data.aws_network_interface.bigip-internal.private_ips[3]]

  depends_on = [
    aws_network_interface.mgmt
  ]

}

resource "aws_route53_record" "bigip-mgmt" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bigip-mgmt.de1chk1nd-mcn.aws"
  type    = "A"
  ttl     = "300"
  records = [data.aws_network_interface.bigip-mgmt.private_ips[0]]

  depends_on = [
    aws_network_interface.mgmt
  ]

}