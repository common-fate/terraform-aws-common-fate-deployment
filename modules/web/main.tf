######################################################
# Frontend Task
######################################################
resource "aws_security_group" "ecs_frontend_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-ecs-frontend-sg"
  }
}

resource "aws_iam_role" "frontend_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-frontend-ecs-execution-role"
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
resource "aws_iam_role_policy_attachment" "frontend_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.frontend_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "${var.namespace}-${var.stage}-frontend-lg"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "${var.namespace}-${var.stage}-frontend-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.frontend_ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "frontend_container",
    image = "commonfate/common-fate-cloud-web:${var.release_tag}",

    memory = 256,
    portMappings = [{
      containerPort = 80,
      hostPort      = 80
    }],


    environment = [
      {
        name  = "CF_OAUTH_CLIENT_ID"
        value = var.auth_web_client_id
      },
      {
        name  = "CF_CLI_OAUTH_CLIENT_ID"
        value = var.auth_cli_client_id
      },
      {
        name  = "CF_OAUTH_AUTH_URL"
        value = var.auth_authority_url
      },
      {
        name  = "CF_API_URL"
        value = var.api_domain
      },
      {
        name  = "CF_AUTHZ_URL",
        value = var.authz_domain
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
        value = var.auth_domain
      },
      {
        name  = "CF_COGNITO_REGION"
        value = var.aws_region
      }


    ]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.frontend_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "frontend"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_frontend_sg.id]
    }
  }])
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.namespace}-${var.stage}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = {
    Name = "${var.namespace}-${var.stage}-frontend-tg"
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.namespace}-${var.stage}-frontend-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_frontend_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend_container"
    container_port   = 80
  }
}
resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.frontend_domain, "https://", "")]
    }
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-web-rule"
  }
}
