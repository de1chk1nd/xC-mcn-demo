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
  records = [data.aws_network_interface.xc_private_nic.private_ip]

  depends_on = [
    data.aws_network_interface.xc_private_nic
  ]

}