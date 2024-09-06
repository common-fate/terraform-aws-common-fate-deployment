######################################################
# Web Task
######################################################
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_web_sg_v2" {
  name        = "${var.namespace}-${var.stage}-web"
  description = "Common Fate Web networking"
  vpc_id      = var.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role" "web_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-web-ecs-er"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:*"
          }
          StringEquals = {
            "aws:SourceAccount" : "${var.aws_account_id}"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "web_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.web_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_cloudwatch_log_group" "web_log_group" {
  name              = "${var.namespace}-${var.stage}-web"
  retention_in_days = var.log_retention_in_days

}

resource "aws_ecs_task_definition" "web_task" {
  family                   = "${var.namespace}-${var.stage}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.web_ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "web_container",
    image = "${var.web_image_repository}:${var.release_tag}",

    portMappings = [{
      containerPort = 80,
      hostPort      = 80
    }],


    environment = [
      {
        name  = "CF_OIDC_CLIENT_ID"
        value = var.auth_web_client_id
      },
      {
        name  = "CF_CLI_OIDC_CLIENT_ID"
        value = var.auth_cli_client_id
      },
      {
        name  = "CF_OIDC_AUTHORITY_URL"
        value = var.auth_authority_url
      },
      {
        name  = "CF_OIDC_ISSUER"
        value = var.auth_issuer
      },
      {
        name  = "CF_API_URL"
        value = coalesce(var.controlplane_api_url, var.app_url)
      },
      {
        name  = "CF_ACCESS_API_URL"
        value = coalesce(var.access_api_url, var.app_url)
      },
      {
        name  = "CF_AUTHZ_URL",
        value = coalesce(var.authz_api_url, var.app_url)
      },
      {
        name  = "CF_AUTHZ_GRAPH_URL",
        value = "${coalesce(var.authz_api_url, var.app_url)}/graph"
      },
      {
        name  = "CF_COGNITO_USER_POOL_DOMAIN"
        value = var.auth_url
      },
      {
        name  = "CF_COGNITO_REGION"
        value = var.aws_region
      },
      {
        name  = "CF_RELEASE_TAG",
        value = var.release_tag
      },
      {
        name  = "CF_CENTRALISED_SUPPORT",
        value = var.centralised_support ? "true" : "false"
      },
      // @TODO: remove once the flag is removed in the web app
      {
        name  = "CF_HIERARCHY_UI",
        value = "true"
      },
    ]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.web_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "frontend"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_web_sg_v2.id]
    }
  }])
}

resource "aws_lb_target_group" "web_tg" {
  name        = "${var.namespace}-${var.stage}-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_ecs_service" "web_service" {
  name            = "${var.namespace}-${var.stage}-web"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.web_task.arn
  launch_type     = "FARGATE"

  desired_count = var.desired_task_count

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_web_sg_v2.id]
  }

  dynamic "load_balancer" {
    for_each = toset(local.web_target_group_arns)
    content {
      target_group_arn = load_balancer.value
      container_name   = "web_container"
      container_port   = 80
    }
  }
}
resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.app_url, "https://", "")]
    }
  }

}
locals {
  web_target_group_arns = var.additional_target_groups != [] ? concat([aws_lb_target_group.web_tg.arn], var.additional_target_groups) : [aws_lb_target_group.web_tg.arn]
}
