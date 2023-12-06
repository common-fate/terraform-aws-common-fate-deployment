######################################################
# Load Balancer
######################################################
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  name   = "${var.namespace}-${var.stage}-alb-security-group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_lb" "main_alb" {
  name                             = "${var.namespace}-${var.stage}-common-fate"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = var.public_subnet_ids
  enable_cross_zone_load_balancing = true

}

resource "aws_lb_listener" "web_listener" {
  count             = var.web_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.web_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Common Fate)"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "control_plane_listener" {
  count             = var.control_plane_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.control_plane_certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Common Fate)"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "authz_listener" {
  count             = var.authz_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.authz_certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Common Fate)"
      status_code  = "404"
    }
  }
}
resource "aws_lb_listener" "access_handler_listener" {
  count             = var.access_handler_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.access_handler_certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Common Fate)"
      status_code  = "404"
    }
  }
}
