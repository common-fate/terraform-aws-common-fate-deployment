
######################################################
# Control Plane
######################################################

#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_control_plane_sg_v2" {
  name        = "${var.namespace}-${var.stage}-control-plane"
  description = "Common Fate Control Plane networking"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }

}

#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_worker_sg" {
  name        = "${var.namespace}-${var.stage}-worker"
  description = "Common Fate Worker networking"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Update the RDS security group to allow connections from the ECS worker service
resource "aws_security_group_rule" "rds_access_from_worker" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.ecs_worker_sg.id
}


# Update the RDS security group to allow connections from the ECS control-plane service
resource "aws_security_group_rule" "rds_access_from_control_plane" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.ecs_control_plane_sg_v2.id
}


resource "aws_cloudwatch_log_group" "control_plane_log_group" {
  name              = "${var.namespace}-${var.stage}-control-plane"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "worker_log_group" {
  name              = "${var.namespace}-${var.stage}-worker"
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

resource "aws_iam_policy" "parameter_store_secrets_read_access" {
  name        = "${var.namespace}-${var.stage}-control-plane-ps"
  description = "Allows reading secrets from SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    // include only the secrets that are configured
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:${var.aws_partition}:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.namespace}/${var.stage}/*",
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "control_plane_ecs_task_parameter_store_secrets_read_access_attach" {
  role       = aws_iam_role.control_plane_ecs_execution_role.name
  policy_arn = aws_iam_policy.parameter_store_secrets_read_access.arn
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

resource "aws_iam_role_policy_attachment" "control_plane_ecs_task_parameter_store_secrets_read_access_attach_tr" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.parameter_store_secrets_read_access.arn
}


resource "aws_iam_role_policy_attachment" "otel" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = var.otel_writer_iam_policy_arn
}

resource "aws_iam_policy" "report_bucket" {
  name        = "${var.namespace}-${var.stage}-control-plane-reports"
  description = "Allows the Control Plane to read and write from the Report S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [var.report_bucket_arn]
      },
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:*Object",
        "Resource" : ["${var.report_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "control_plane_report_bucket_attach" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.report_bucket.arn
}


resource "aws_iam_policy" "authz_eval_bucket" {
  name        = "${var.namespace}-${var.stage}-control-plane-eval-bucket"
  description = "Allows the Control Plane to read from the authorization evaluation S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [var.authz_eval_bucket_arn]
      },
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:GetObject",
        "Resource" : ["${var.authz_eval_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "control_plane_authz_eval_bucket_attach" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.authz_eval_bucket.arn
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
  count = length(var.grant_assume_on_role_arns) > 0 ? 1 : 0
  statement {
    actions   = ["sts:AssumeRole"]
    resources = var.grant_assume_on_role_arns
  }
}
resource "aws_iam_policy" "assume_role" {
  count       = length(var.grant_assume_on_role_arns) > 0 ? 1 : 0
  name        = "${var.namespace}-${var.stage}-access-handler-ars"
  description = "A policy allowing sts:AssumeRole on specific roles roles"
  policy      = data.aws_iam_policy_document.assume_roles_policy[0].json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach" {
  count      = length(var.grant_assume_on_role_arns) > 0 ? 1 : 0
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_role[0].arn
}

data "aws_iam_policy_document" "assume_roles_policy_tagged" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/common-fate-aws-integration-read-role"
      values   = ["true"]
    }
  }
}
resource "aws_iam_policy" "assume_role_tagged" {
  name        = "${var.namespace}-${var.stage}-access-handler-ars-tagged"
  description = "A policy allowing sts:AssumeRole on roles tagged with common-fate-aws-integration-read-role"
  policy      = data.aws_iam_policy_document.assume_roles_policy_tagged.json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach_tagged" {
  role       = aws_iam_role.control_plane_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_role_tagged.arn
}


locals {
  control_plane_environment = [
    {
      name  = "CF_SCIM_SOURCE",
      value = var.scim_source
    },
    // used for auth middleware
    {
      name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
      value = var.auth_issuer
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
      name  = "CF_PAGERDUTY_REDIRECT_URL",
      value = "${var.app_url}/api/v1/oauth2/callback/pagerduty"
    },
    {
      name  = "CF_FRONTEND_URL",
      value = var.app_url
    },
    {
      name  = "CF_API_URL",
      value = var.app_url
    },
    {
      name = "CF_AUTHZ_URL",
      # value = var.app_url

      value = var.authz_service_connect_address

    },
    {
      name = "CF_ACCESS_URL",
      # value = var.app_url
      value = var.access_handler_service_connect_address

    },
    {
      name  = "CF_SLACK_CLIENT_ID",
      value = var.slack_client_id
    },

    {
      name  = "CF_SLACK_REDIRECT_URL",
      value = "${var.app_url}/api/v1/oauth2/callback/slack"
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
      name  = "CF_CONTROL_PLANE_SERVICE_OIDC_CLIENT_ID",
      value = var.control_plane_service_client_id
    },
    {
      name  = "CF_CONTROL_PLANE_SERVICE_OIDC_CLIENT_SECRET",
      value = var.control_plane_service_client_secret
    },
    {
      name  = "CF_CONTROL_PLANE_SERVICE_OIDC_ISSUER",
      value = var.oidc_control_plane_issuer
    },
    {
      name  = "CF_SLACK_SERVICE_OIDC_CLIENT_ID",
      value = var.slack_service_client_id
    },
    {
      name  = "CF_SLACK_SERVICE_OIDC_CLIENT_SECRET",
      value = var.slack_service_client_secret
    },
    {
      name  = "CF_SLACK_SERVICE_OIDC_ISSUER",
      value = var.oidc_slack_issuer
    },
    { name  = "CF_CORS_ALLOWED_ORIGINS"
      value = join(",", concat([var.app_url], var.additional_cors_allowed_origins))
    },
    {
      name  = "LOG_LEVEL"
      value = var.log_level
    },
    {
      name  = "CF_SYNC_PAGERDUTY_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_PAGERDUTY_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_OPSGENIE_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_OPSGENIE_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_GCP_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_GCP_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_PROPAGATE_ENABLED",
      value = "true"
    },
    {
      name  = "CF_PROPAGATE_CRON_SCHEDULE",
      value = "*/1 * * * *"
    },
    {
      name  = "CF_MAKE_AVAILABLE_ENABLED",
      value = "true"
    },
    {
      name  = "CF_MAKE_AVAILABLE_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_AWSIDC_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_AWSIDC_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_AWSRDS_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_AWSRDS_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_OKTA_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_OKTA_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_SYNC_DATASTAX_ENABLED",
      value = "true"
    },
    {
      name  = "CF_SYNC_DATASTAX_CRON_SCHEDULE",
      value = "*/5 * * * *"
    },
    {
      name  = "CF_FEATURE_LEAST_PRIVILEGE_ENABLED",
      value = var.unstable_enable_feature_least_privilege ? "true" : "false"
    },
    {
      name  = "CF_SYNC_IDC_CLOUDTRAIL_CRON_SCHEDULE",
      value = var.unstable_sync_idc_cloudtrail_schedule
    },
    {
      name  = "CF_LEAST_PRIVILEGE_ANALYSIS_CRON_SCHEDULE",
      value = var.unstable_least_privilege_analysis_schedule
    },
    {
      name  = "CF_REPORT_S3_BUCKET",
      value = var.report_bucket_name
    },
    {
      name  = "CF_ASSUME_ROLE_EXTERNAL_ID",
      value = var.assume_role_external_id
    },
    {
      name  = "CF_EVAL_SINK_AWS_S3_BUCKET",
      value = var.authz_eval_bucket_name
    },
    {
      name  = "CF_RELEASE_TAG",
      value = var.release_tag
    },
    {
      name  = "CF_FEATURE_ACCESS_SIMULATION_ENABLED",
      value = var.unstable_enable_feature_access_simulation ? "true" : "false"
    }


  ]

  // Only add these secrets if their values are provided
  control_plane_secrets = concat(
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

  ])
}
resource "aws_ecs_task_definition" "control_plane_task" {
  family                   = "${var.namespace}-${var.stage}-control-plane"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.control_plane_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.control_plane_ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "control-plane-container",
      image = "${var.control_image_repository}:${var.release_tag}",

      portMappings = [{
        containerPort = 8080,
        name          = "control_plane"
      }],

      environment = local.control_plane_environment
      secrets     = local.control_plane_secrets

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
        securityGroupIds = [aws_security_group.ecs_control_plane_sg_v2.id]
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
          "awslogs-stream-prefix" = "control-plane"
        }
      },
      healthCheck = {
        "command"     = ["/healthcheck"],
        "interval"    = 5,
        "timeout"     = 6,
        "retries"     = 5,
        "startPeriod" = 1
      }
    },
  ])
}

resource "aws_ecs_task_definition" "worker_task" {
  family                   = "${var.namespace}-${var.stage}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_worker_task_cpu
  memory                   = var.ecs_worker_task_memory
  execution_role_arn       = aws_iam_role.control_plane_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.control_plane_ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "worker-container",
      image = "${var.worker_image_repository}:${var.release_tag}",

      environment = local.control_plane_environment
      secrets     = local.control_plane_secrets

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker_log_group.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "worker"
        }
      },

      # Link to the security group
      linuxParameters = {
        securityGroupIds = [aws_security_group.ecs_worker_sg.id]
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
          "awslogs-stream-prefix" = "worker"
        }
      },
      healthCheck = {
        "command"     = ["/healthcheck"],
        "interval"    = 5,
        "timeout"     = 6,
        "retries"     = 5,
        "startPeriod" = 1
      }
    },
  ])
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



  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
    service {
      discovery_name = "control_plane-grpc"
      port_name      = "control_plane"
      client_alias {
        port     = 8080
        dns_name = "control_plane.grpc"
      }
    }
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_control_plane_sg_v2.id]
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
  priority     = 90
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_plane_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.app_url, "https://", "")]
    }
  }
  condition {
    path_pattern {
      values = ["/commonfate.control*", "/api/*", "/commonfate.leastprivilege*"]
    }
  }
}



resource "aws_ecs_service" "worker_service" {
  name            = "${var.namespace}-${var.stage}-worker"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.worker_task.arn
  launch_type     = "FARGATE"

  desired_count = var.desired_worker_task_count

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
    # service {
    #   discovery_name = "worker-grpc"
    #   port_name      = "worker"
    #   client_alias {
    #     port     = 8080
    #     dns_name = "worker.grpc"
    #   }
    # }
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_worker_sg.id]
  }
}
