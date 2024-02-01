######################################################
# Web Task
######################################################
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_web_sg" {

  vpc_id      = var.vpc_id
  description = "allow access from the alb"

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
    image = "commonfate/common-fate-cloud-web:${var.release_tag}",

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
        value = var.app_url
      },
      {
        name  = "CF_ACCESS_API_URL"
        value = var.app_url
      },
      {
        name  = "CF_AUTHZ_URL",
        value = var.app_url
      },
      {
        name  = "CF_AUTHZ_GRAPH_URL",
        value = "${var.app_url}/graph"
      },
      {
        name  = "CF_TEAM_NAME"
        value = var.team_name
      },
      {
        name  = "CF_FAVICON_URL"
        value = var.favicon_url
      },
      {
        name  = "CF_LOGO_URL"
        value = var.logo_url
      },
      {
        name  = "CF_COGNITO_USER_POOL_DOMAIN"
        value = var.auth_url
      },
      {
        name  = "CF_COGNITO_REGION"
        value = var.aws_region
      }
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
      securityGroupIds = [aws_security_group.ecs_web_sg.id]
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

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_web_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "web_container"
    container_port   = 80
  }
}
resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 100
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
