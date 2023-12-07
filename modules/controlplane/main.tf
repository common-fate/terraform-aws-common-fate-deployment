
######################################################
# Control Plane
######################################################

resource "aws_security_group" "ecs_control_plane_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }

}

# Update the RDS security group to allow connections from the ECS control-plane service
resource "aws_security_group_rule" "rds_access_from_control_plane" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.ecs_control_plane_sg.id
}

resource "aws_cloudwatch_log_group" "control_plane_log_group" {
  name              = "${var.namespace}-${var.stage}-control-plane"
  retention_in_days = var.log_retention_in_days
}


# EXECUTION ROLE
resource "aws_iam_role" "control_plane_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-control-plane-ecs-er"
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

resource "aws_iam_role_policy_attachment" "control_plane_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.control_plane_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_policy" "database_secrets_read_access" {
  name        = "${var.namespace}-${var.stage}-control-plane-sm"
  description = "Allows pull database secret from secrets manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          var.database_secret_sm_arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "control_plane_ecs_task_database_secrets_access_attach" {
  role       = aws_iam_role.control_plane_ecs_execution_role.name
  policy_arn = aws_iam_policy.database_secrets_read_access.arn
}

locals {
  secret_arns = {
    for arn in [
      var.pager_duty_client_secret_ps_arn,
      var.slack_client_secret_ps_arn,
      var.slack_signing_secret_ps_arn,
      var.scim_token_ps_arn,
      var.licence_key_ps_arn
    ] : arn => arn
    if arn != ""
  }

}

resource "aws_iam_policy" "parameter_store_secrets_read_access" {
  count       = length(local.secret_arns) > 0 ? 1 : 0
  name        = "${var.namespace}-${var.stage}-control-plane-ps"
  description = "Allows read secret from parameter store"

  policy = jsonencode({
    Version = "2012-10-17",
    // include only the secrets that are configured
    Statement = [
      for arn in local.secret_arns :
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
        ]
        Resource = arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "control_plane_ecs_task_parameter_store_secrets_read_access_attach" {
  count      = length(local.secret_arns) > 0 ? 1 : 0
  role       = aws_iam_role.control_plane_ecs_execution_role.name
  policy_arn = aws_iam_policy.parameter_store_secrets_read_access[0].arn
}

# TASK ROLE
resource "aws_iam_role" "control_plane_ecs_task_role" {
  name = "${var.namespace}-${var.stage}-control-plane-ecs-tr"
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
resource "aws_iam_policy" "eventbus_put_events" {
  name        = "${var.namespace}-${var.stage}-control-plane-eb"
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
resource "aws_iam_role_policy_attachment" "control_plane_eventbus_put_events_attach" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.eventbus_put_events.arn
}
resource "aws_iam_policy" "sqs_subscribe" {
  name        = "${var.namespace}-${var.stage}-control-plane-sqs"
  description = "Allows access to read sqs queue and delete messages"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
          "sqs:GetQueueUrl"
        ],
        "Resource" : var.sqs_queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "control_plane_sqs_subscribe_attach" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.sqs_subscribe.arn
}

data "aws_iam_policy_document" "assume_roles_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = var.grant_assume_on_role_arns
  }
}
resource "aws_iam_policy" "assume_role" {
  count       = length(var.grant_assume_on_role_arns) > 0 ? 1 : 0
  name        = "${var.namespace}-${var.stage}-access-handler-ars"
  description = "A policy allowing sts:AssumeRole on selected roles"
  policy      = data.aws_iam_policy_document.assume_roles_policy.json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach" {
  count      = length(var.grant_assume_on_role_arns) > 0 ? 1 : 0
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_role[0].arn
}

resource "aws_ecs_task_definition" "control_plane_task" {
  family                   = "${var.namespace}-${var.stage}-control-plane"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.control_plane_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.control_plane_ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "control-plane-container",
    image = "commonfate/common-fate-cloud-api:${var.release_tag}",


    portMappings = [{
      containerPort = 8080,
    }],
    environment = [
      {
        name  = "CF_OIDC_AUTHORITY_URL",
        value = var.auth_authority_url
      },
      {
        name  = "CF_EVENT_BRIDGE_ARN",
        value = var.eventbus_arn
      },
      {
        name  = "CF_EVENT_HANDLER_SQS_QUEUE",
        value = var.sqs_queue_name
      },

      {
        name  = "CF_PAGERDUTY_CLIENT_ID",
        value = var.pager_duty_client_id
      },

      {
        name  = "CF_FRONTEND_URL",
        value = var.web_domain
      },
      {
        name  = "CF_API_URL",
        value = var.control_plane_domain
      },
      {
        name  = "CF_AUTHZ_URL",
        value = var.authz_url
      },
      {
        name  = "CF_ACCESS_URL",
        value = var.access_handler_domain
      },
      {
        name  = "CF_SLACK_CLIENT_ID",
        value = var.slack_client_id
      },

      {
        name  = "CF_SLACK_REDIRECT_URL",
        value = "${var.control_plane_domain}/oauth2/callback/slack"
      },
      {
        name  = "CF_PG_USER",
        value = var.database_user
      },
      {
        name  = "CF_PG_HOST",
        value = var.database_host
      },
      {
        name  = "CF_PG_SSLMode",
        value = "require"
      },
      {
        name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
        value = var.auth_issuer
      },
      {
        name  = "CF_CLEANUP_SERVICE_OIDC_CLIENT_ID",
        value = var.cleanup_service_client_id
      },
      {
        name  = "CF_CLEANUP_SERVICE_OIDC_CLIENT_SECRET",
        value = var.cleanup_service_client_secret
      },
      { name  = "CF_CORS_ALLOWED_ORIGINS"
        value = join(",", [var.web_domain])
      },
      {
        name  = "LOG_LEVEL"
        value = var.enable_verbose_logging ? "DEBUG" : "INFO"

      }

    ],

    // Only add these secrets if their values are provided
    secrets = concat(
      var.pager_duty_client_secret_ps_arn != "" ? [{
        name      = "CF_PAGERDUTY_CLIENT_SECRET",
        valueFrom = var.pager_duty_client_secret_ps_arn
      }] : [],
      var.slack_client_secret_ps_arn != "" ? [{
        name      = "CF_SLACK_CLIENT_SECRET",
        valueFrom = var.slack_client_secret_ps_arn
      }] : [],
      var.slack_signing_secret_ps_arn != "" ? [{
        name      = "CF_SLACK_SIGNING_SECRET",
        valueFrom = var.slack_signing_secret_ps_arn
      }] : [],
      var.scim_token_ps_arn != "" ? [{
        name      = "CF_SCIM_TOKEN",
        valueFrom = var.scim_token_ps_arn
      }] : [],
      [
        {
          name = "CF_PG_PASSWORD",
          // the password key is extracted from the json that is stored in secrets manager so that we don't need to decode it in the go server
          valueFrom = "${var.database_secret_sm_arn}:password::"
        },
        {
          name      = "CF_LICENCE_KEY",
          valueFrom = var.licence_key_ps_arn
        },

      ]
    )

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.control_plane_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "control-plane"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_control_plane_sg.id]
    }
  }])
}


resource "aws_lb_target_group" "control_plane_tg" {
  name        = "${var.namespace}-${var.stage}-control-plane"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled = true
    path    = "/health"
  }

}
resource "aws_ecs_service" "control_plane_service" {
  name            = "${var.namespace}-${var.stage}-control-plane"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.control_plane_task.arn
  launch_type     = "FARGATE"

  desired_count = var.desired_task_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_control_plane_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.control_plane_tg.arn
    container_name   = "control-plane-container"
    container_port   = 8080
  }
}

resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_plane_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.control_plane_domain, "https://", "")]
    }
  }
}
