
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_access_handler_sg_v2" {
  name        = "${var.namespace}-${var.stage}-access-handler"
  description = "Common Fate Access Handler networking"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id, var.worker_security_group_id, var.control_plane_security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_cloudwatch_log_group" "access_handler_log_group" {
  name              = "${var.namespace}-${var.stage}-access-handler"
  retention_in_days = var.log_retention_in_days
}



resource "aws_iam_role" "access_handler_ecs_execution_role" {
  name        = "${var.namespace}-${var.stage}-access-handler-er"
  description = "The execution role used by ECS to run the Access Handler task."
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

resource "aws_iam_role_policy_attachment" "access_handler_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.access_handler_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



# TASK ROLE
resource "aws_iam_role" "access_handler_ecs_task_role" {
  name        = "${var.namespace}-${var.stage}-access-handler-ecs-tr"
  description = "The task role assumed by the Access Handler task."
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

resource "aws_iam_policy" "eventbus_put_events" {
  name        = "${var.namespace}-${var.stage}-access-handler-eb"
  description = "Allows ECS tasks to put events to the event bus"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "events:PutEvents",
        "Resource" : var.eventbus_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "otel" {
  role       = aws_iam_role.access_handler_ecs_task_role.name
  policy_arn = var.otel_writer_iam_policy_arn
}

resource "aws_iam_role_policy_attachment" "access_handler_eventbus_put_events_attach" {
  role       = aws_iam_role.access_handler_ecs_task_role.name
  policy_arn = aws_iam_policy.eventbus_put_events.arn
}

resource "aws_ecs_task_definition" "access_handler_task" {
  family                   = "${var.namespace}-${var.stage}-access-handler"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  execution_role_arn = aws_iam_role.access_handler_ecs_execution_role.arn
  task_role_arn      = aws_iam_role.access_handler_ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "access-handler-container",
      image = "${var.access_image_repository}:${var.release_tag}",

      portMappings = [{
        containerPort = 9090,
        name          = "grpc"
        appProtocol   = "http"
      }],
      environment = [
        {
          name  = "CF_EVENT_BRIDGE_ARN",
          value = var.eventbus_arn
        },
        {
          name  = "CF_AUTHZ_URL",
          value = var.authz_service_connect_address
        },
        {
          name  = "CF_FRONTEND_URL",
          value = var.app_url
        },
        {
          name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
          value = var.auth_issuer
        },
        { name  = "CF_CORS_ALLOWED_ORIGINS"
          value = join(",", concat([var.app_url], var.additional_cors_allowed_origins))
        },
        {
          name  = "LOG_LEVEL"
          value = var.log_level
        },
        {
          name  = "CF_ACCESS_SERVICE_CLIENT_ID",
          value = var.oidc_access_handler_service_client_id
        },
        {
          name  = "CF_ACCESS_SERVICE_CLIENT_SECRET",
          value = var.oidc_access_handler_service_client_secret
        },
        {
          name  = "CF_ACCESS_SERVICE_OIDC_ISSUER",
          value = var.oidc_access_handler_service_issuer
        },
        {
          name  = "CF_RELEASE_TAG",
          value = var.release_tag
        }
      ],
      secrets = [

      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.access_handler_log_group.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "access-handler"
        }
      },

      # Link to the security group
      linuxParameters = {
        securityGroupIds = [aws_security_group.ecs_access_handler_sg_v2.id]
      }
    },
    {
      name      = "aws-otel-collector",
      image     = "amazon/aws-otel-collector",
      command   = ["--config=/etc/ecs/ecs-default-config.yaml"],
      essential = true,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = var.otel_log_group_name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "access-handler"
        }
      },
      healthCheck = {
        "command"     = ["/healthcheck"],
        "interval"    = 5,
        "timeout"     = 6,
        "retries"     = 5,
        "startPeriod" = 1
      }
    }
  ])

}

resource "aws_lb_target_group" "access_handler_tg" {
  name        = "${var.namespace}-${var.stage}-access-handler"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled = true
    path    = "/health"
  }

}



resource "aws_ecs_service" "access_handler_service" {
  name            = "${var.namespace}-${var.stage}-access-handler"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.access_handler_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_task_count

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_access_handler_sg_v2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.access_handler_tg.arn
    container_name   = "access-handler-container"
    container_port   = 9090
  }


  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
    service {
      discovery_name = "access-grpc"
      port_name      = "grpc"
      client_alias {
        port     = 9090
        dns_name = "access.grpc"
      }
    }
  }
}

resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 60
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.access_handler_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.app_url, "https://", "")]
    }
  }
  condition {
    path_pattern {
      values = ["/commonfate.access*"]
    }
  }
}


