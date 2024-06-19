######################################################
# AWS RDS Proxy ECS Task
######################################################

data "aws_caller_identity" "current" {}

locals {
  name_prefix = join("-", compact([var.namespace, var.stage, var.name_prefix]))
}

#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_rds_proxy_sg" {
  name        = "${local.name_prefix}-rds-proxy"
  description = "Common Fate RDS Proxy networking"

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



resource "aws_cloudwatch_log_group" "rds_proxy_log_group" {
  name              = "${local.name_prefix}-rds-proxy"
  retention_in_days = var.log_retention_in_days

}



resource "aws_iam_role" "rds_proxy_ecs_execution_role" {
  name        = "${local.name_prefix}-rds-proxy-er"
  description = "The execution role used by ECS to run the RDS Proxy task."
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
resource "aws_iam_role_policy_attachment" "rds_proxy_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.rds_proxy_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# TASK ROLE
# The task role will be configured to have assuem role permissions on specific roles
# these roles are configured in the terraform config provider along with the webhooks
resource "aws_iam_role" "rds_proxy_ecs_task_role" {
  name        = "${local.name_prefix}-rds-proxy-ecs-tr"
  description = "The task role assumed by the RDS Proxy task."
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

# resource "aws_iam_role_policy_attachment" "otel" {
#   role       = aws_iam_role.rds_proxy_ecs_task_role.name
#   policy_arn = var.otel_writer_iam_policy_arn
# }

data "aws_iam_policy_document" "assume_roles_policy_tagged" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/common-fate-aws-integration-provision-role"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "assume_rds_proxy_role_tagged" {
  name        = "${local.name_prefix}-rds-proxy-ar-tagged"
  description = "A policy allowing sts:AssumeRole on roles tagged with common-fate-aws-integration-provision-role"
  policy      = data.aws_iam_policy_document.assume_roles_policy_tagged.json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach_tagged" {
  role       = aws_iam_role.rds_proxy_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_rds_proxy_role_tagged.arn
}

resource "aws_ecs_task_definition" "rds_proxy_task" {
  family                   = "${local.name_prefix}-rds-proxy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  execution_role_arn = aws_iam_role.rds_proxy_ecs_execution_role.arn
  task_role_arn      = aws_iam_role.rds_proxy_ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "aws-rds-proxy-container",
    image = "${var.rds_proxy_image_repository}:${var.release_tag}",

    portMappings = [{
      containerPort = 9999,
    }],
    environment = [
      {
        name  = "LOG_LEVEL"
        value = var.enable_verbose_logging ? "DEBUG" : "INFO"
      },
      {
        name  = "CF_RELEASE_TAG"
        value = var.release_tag
      },
      {
        name  = "CF_ACCESS_URL"
        value = var.app_url
      },
      {
        name  = "CF_CLIENT_ID"
        value = var.rds_proxy_service_client_id
      },
      {
        name  = "CF_CLIENT_SECRET"
        value = var.rds_proxy_service_client_secret
      },
      {
        name  = "CF_OIDC_ISSUER"
        value = var.auth_issuer
      },
      {
        name  = "CF_DATABASE_CONNECTION_STRING"
        value = var.database_connection_string
      },



      # {
      #   name  = "CF_LICENCE_KEY",
      #   value = var.licence_key
      # },
      # {
      #   name  = "CF_FACTORY_BASE_URL",
      #   value = var.factory_base_url
      # },
      # {
      #   name  = "CF_FACTORY_OIDC_ISSUER",
      #   value = var.factory_oidc_issuer
      # },
      # {
      #   name  = "CF_MONITORING_LOCAL_ENABLED",
      #   value = var.xray_monitoring_enabled ? "true" : "false"
      # },
      # {
      #   name  = "CF_MONITORING_MANAGED_ENABLED",
      #   value = var.managed_monitoring_enabled ? "true" : "false"
      # },
      # {
      #   name  = "CF_MONITORING_MANAGED_ENDPOINT",
      #   value = var.managed_monitoring_endpoint
      # },
      {
        name  = "CF_DEPLOYMENT_NAME",
        value = var.stage
      },
    ],


    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.rds_proxy_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "aws-rds-proxy"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_rds_proxy_sg_v2.id]
    }
    },
    # {
    #   name      = "aws-otel-collector",
    #   image     = "amazon/aws-otel-collector",
    #   command   = ["--config=/etc/ecs/ecs-default-config.yaml"],
    #   essential = true,
    #   logConfiguration = {
    #     logDriver = "awslogs",
    #     options = {
    #       "awslogs-group"         = var.otel_log_group_name,
    #       "awslogs-region"        = var.aws_region,
    #       "awslogs-stream-prefix" = "aws-rds-proxy"
    #     }
    #   },
    #   healthCheck = {
    #     "command"     = ["/healthcheck"],
    #     "interval"    = 5,
    #     "timeout"     = 6,
    #     "retries"     = 5,
    #     "startPeriod" = 1
    #   }
    # },
  ])

}


resource "aws_ecs_service" "rds_proxy_service" {
  name            = "${local.name_prefix}-rds-proxy"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.rds_proxy_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_task_count

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_rds_proxy_sg_v2.id]
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_discovery_namespace_arn
  }
}
