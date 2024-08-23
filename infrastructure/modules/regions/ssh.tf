resource "aws_key_pair" "generated_key" {
  key_name   = "${var.student}-${var.region}-ssh_key"
  public_key = var.public_key
  tags = {
    Name  = "${var.student}-${var.region}-xC-mcn-ssh_key"
  }
}