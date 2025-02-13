########################################################################
# NLB to CE Instance
########################################################################

# Create Elastic IP
resource "aws_eip" "ce_nlb_eip" {
  domain = "vpc"
  tags = {
    Name = "f5-ce-nlb-eip"
  }
}

# Create Network Load Balancer
resource "aws_lb" "ce-nlb" {
  name               = "f5-ce-nlb"
  internal           = false
  load_balancer_type = "network"
  #subnets            = [aws_subnet.xC-mcn-site-subnet.id]
  security_groups = [aws_security_group.xC-mcn-site-allow-ubuntu.id]

  subnet_mapping {
    subnet_id       = aws_subnet.xC-mcn-site-subnet.id
    allocation_id   = aws_eip.ce_nlb_eip.id
    }

  enable_deletion_protection = false
}

# Create HTTP target group (port 80)
resource "aws_lb_target_group" "ce-target_group_http" {
  name        = "f5-ce-tg-http"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.xC-mcn-site.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    port               = "traffic-port"
    protocol           = "TCP"
    unhealthy_threshold = 3
  }
}

# Create HTTPS target group (port 443)
resource "aws_lb_target_group" "ce-target_group_https" {
  name        = "f5-ce-tg-https"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.xC-mcn-site.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    port               = "traffic-port"
    protocol           = "TCP"
    unhealthy_threshold = 3
  }
}

# Data source to get ENI information
data "aws_network_interface" "target_eni" {
  id = aws_network_interface.xC-mcn-slo-v2.id
}

# Attach the EC2 instance to HTTP target group
resource "aws_lb_target_group_attachment" "ce-target_attachment_http" {
  target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  target_id        = data.aws_network_interface.target_eni.private_ip
  port             = 80
}

# Attach the EC2 instance to HTTPS target group
resource "aws_lb_target_group_attachment" "ce-target_attachment_https" {
  target_group_arn = aws_lb_target_group.ce-target_group_https.arn
  target_id        = data.aws_network_interface.target_eni.private_ip
  port             = 443
}

# Create HTTP listener (port 80)
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.ce-nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  }
}

# Create HTTPS listener (port 443)
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.ce-nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ce-target_group_https.arn
  }
}

########################################################################
# NLB to Ubuntu Server
########################################################################

# Create Elastic IP
resource "aws_eip" "ubuntu_nlb_eip" {
  domain = "vpc"
  tags = {
    Name = "f5-ubuntu-nlb-eip"
  }
}

# Create Network Load Balancer
resource "aws_lb" "ubuntu-nlb" {
  name               = "f5-ubuntu-nlb"
  internal           = false
  load_balancer_type = "network"
  #subnets            = [aws_subnet.xC-mcn-site-subnet.id]
  security_groups = [aws_security_group.xC-mcn-site-allow-ubuntu.id]

  subnet_mapping {
    subnet_id       = aws_subnet.xC-mcn-site-subnet.id
    allocation_id   = aws_eip.ubuntu_nlb_eip.id
    }

  enable_deletion_protection = false
}

# Create HTTP target group (port 22)
resource "aws_lb_target_group" "ubuntu-target_group_http" {
  name        = "f5-ubuntu-tg-http"
  port        = 22
  protocol    = "TCP"
  vpc_id      = aws_vpc.xC-mcn-site.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    port               = "traffic-port"
    protocol           = "TCP"
    unhealthy_threshold = 3
  }
}

# Data source to get ENI information
data "aws_network_interface" "ubuntu_eni" {
  id = aws_network_interface.xC-mcn-site-ubuntu-public.id
}

# Attach the EC2 instance to HTTP target group
resource "aws_lb_target_group_attachment" "ubuntu-target_attachment_http" {
  target_group_arn = aws_lb_target_group.ubuntu-target_group_http.arn
  target_id        = data.aws_network_interface.ubuntu_eni.private_ip
  port             = 22
}

# Create HTTP listener (port 22)
resource "aws_lb_listener" "listener_ssh" {
  load_balancer_arn = aws_lb.ubuntu-nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ubuntu-target_group_http.arn
  }
}