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
data "aws_network_interface" "target_eni-01" {
  id = aws_network_interface.xC-mcn-slo-v2-publ-01.id
}

data "aws_network_interface" "target_eni-02" {
  id = aws_network_interface.xC-mcn-slo-v2-publ-02.id
}

# Attach the EC2 instance to HTTP target group
resource "aws_lb_target_group_attachment" "target_attachment_http_01" {
  target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  target_id        = data.aws_network_interface.target_eni-01.private_ip
  port             = 80
}
resource "aws_lb_target_group_attachment" "target_attachment_http_02" {
  target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  target_id        = data.aws_network_interface.target_eni-02.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "target_attachment_https_01" {
  target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  target_id        = data.aws_network_interface.target_eni-01.private_ip
  port             = 443
}
resource "aws_lb_target_group_attachment" "target_attachment_https_02" {
  target_group_arn = aws_lb_target_group.ce-target_group_http.arn
  target_id        = data.aws_network_interface.target_eni-02.private_ip
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
  security_groups = [
    aws_security_group.xC-mcn-site-allow-linux.id,
    aws_security_group.xC-mcn-site-inc-americas.id,
    aws_security_group.xC-mcn-site-inc-europe.id,
    aws_security_group.xC-mcn-site-inc-asia.id
    ]

  subnet_mapping {
    subnet_id       = aws_subnet.xC-mcn-site-subnet.id
    allocation_id   = aws_eip.ubuntu_nlb_eip.id
    }

  enable_deletion_protection = false
}

# Create HTTP target group (port 22)
resource "aws_lb_target_group" "ubuntu-target_group_ssh" {
  name        = "f5-ubuntu-tg-ssh"
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

# Create HTTP target group (port 80)
resource "aws_lb_target_group" "ubuntu-target_group_http" {
  name        = "f5-ubuntu-tg-http"
  port        = 10080
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

# Create HTTP target group (port 443)
resource "aws_lb_target_group" "ubuntu-target_group_https" {
  name        = "f5-ubuntu-tg-https"
  port        = 10443
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
resource "aws_lb_target_group_attachment" "ubuntu-target_attachment_ssh" {
  target_group_arn = aws_lb_target_group.ubuntu-target_group_ssh.arn
  target_id        = data.aws_network_interface.ubuntu_eni.private_ip
  port             = 22
}
resource "aws_lb_target_group_attachment" "ubuntu-target_attachment_http" {
  target_group_arn = aws_lb_target_group.ubuntu-target_group_http.arn
  target_id        = data.aws_network_interface.ubuntu_eni.private_ip
  port             = 10080
}
resource "aws_lb_target_group_attachment" "ubuntu-target_attachment_https" {
  target_group_arn = aws_lb_target_group.ubuntu-target_group_https.arn
  target_id        = data.aws_network_interface.ubuntu_eni.private_ip
  port             = 10443
}

# Create HTTP listener (port 22)
resource "aws_lb_listener" "ubuntu-listener_ssh" {
  load_balancer_arn = aws_lb.ubuntu-nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ubuntu-target_group_ssh.arn
  }
}
# Create HTTP listener (port 80)
resource "aws_lb_listener" "ubuntu-listener_http" {
  load_balancer_arn = aws_lb.ubuntu-nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ubuntu-target_group_http.arn
  }
}
# Create HTTP listener (port 443)
resource "aws_lb_listener" "ubuntu-listener_https" {
  load_balancer_arn = aws_lb.ubuntu-nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ubuntu-target_group_https.arn
  }
}

########################################################################
# NLB to internal BigIP MGMT
########################################################################

# Create Network Load Balancer
resource "aws_lb" "bigip-mgmt-nlb" {
  name               = "f5-bigip-mgmt-nlb"
  internal           = true
  load_balancer_type = "network"

  subnets = [aws_subnet.xC-mcn-site-subnet-priv.id]

  security_groups = [aws_security_group.xC-mcn-site-allow-bigip-mgmt.id]

  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
}

# Create target group any port
resource "aws_lb_target_group" "bigip-mgmt-tg" {
  name     = "f5-bigimgmt-tg-443"
  port     = 443  # Use port 0 to indicate any port
  protocol = "TCP"
  vpc_id   = aws_vpc.xC-mcn-site.id
  
  target_type = "ip"
  
  health_check {
    protocol            = "TCP"
    port                = "traffic-port"  # Use the same port for health check
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
  
  preserve_client_ip = true
}

# Data source to get ENI information
data "aws_network_interface" "bigip-mgmt_eni" {
  id = aws_network_interface.mgmt.id
}

# Attach the EC2 instance to HTTP target group
resource "aws_lb_target_group_attachment" "bigip-mgmt-target_attachment_http" {
  target_group_arn = aws_lb_target_group.bigip-mgmt-tg.arn
  target_id        = data.aws_network_interface.bigip-mgmt_eni.private_ip
  port             = 443
}

# TCP listener for port 443 (HTTPS)
resource "aws_lb_listener" "bigip-mgmt-listener" {
  load_balancer_arn = aws_lb.bigip-mgmt-nlb.arn
  port              = 443
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bigip-mgmt-tg.arn
  }
}