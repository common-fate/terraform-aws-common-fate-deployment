######################################################
# Load Balancer
######################################################
#trivy:ignore:AVD-AWS-0104
#trivy:ignore:AVD-AWS-0107
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

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#trivy:ignore:AVD-AWS-0053 
resource "aws_lb" "main_alb" {
  name                             = "${var.namespace}-${var.stage}-common-fate"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = var.public_subnet_ids
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true

}

// The listener is configured to use SNI for multiple certificates if provided
// else it will just use a single cert if all provided arns are the same
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Common Fate)"
      status_code  = "404"
    }
  }
}

# http to https redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}

// if there are any other distict certificates, add them to the listener
resource "aws_lb_listener_certificate" "additional_certs" {
  for_each        = toset(var.additional_certificate_arns)
  listener_arn    = aws_lb_listener.https_listener.arn
  certificate_arn = each.value
}
