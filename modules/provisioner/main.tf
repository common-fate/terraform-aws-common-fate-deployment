######################################################
# Provisioner

# This module is designed to be configured for one or more provisioner types
# You can also deploy multiple instances of the module by setting the 'name' parameter
######################################################

data "aws_caller_identity" "current" {}

locals {
  name_prefix = join("-", compact([var.namespace, var.stage, var.name_prefix]))
}

# Use 'local.combined_env_vars' wherever you need to pass these environment variables
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_provisioner_sg_v2" {
  name        = "${local.name_prefix}-provisioner"
  description = "Common Fate Provisioner networking"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    // Only allow incoming traffic from the provided security group IDs
    security_groups = concat(var.allow_ingress_from_sg_ids, [var.access_handler_sg_id])
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_cloudwatch_log_group" "provisioner_log_group" {
  name              = "${local.name_prefix}-provisioner"
  retention_in_days = var.log_retention_in_days

}



resource "aws_iam_role" "provisioner_ecs_execution_role" {
  name        = "${local.name_prefix}-provisioner-er"
  description = "The execution role used by ECS to run the Provisioner task."
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
resource "aws_iam_role_policy_attachment" "provisioner_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.provisioner_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# TASK ROLE
# The task role will be configured to have assuem role permissions on specific roles
# these roles are configured in the terraform config provider along with the webhooks
resource "aws_iam_role" "provisioner_ecs_task_role" {
  name        = "${local.name_prefix}-provisioner-ecs-tr"
  description = "The task role assumed by the Provisioner task."
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


resource "aws_iam_policy" "parameter_store_secrets_read_access" {
  name        = "${local.name_prefix}-provisioner-ps"
  description = "Allows reading secrets from SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
        ]
        Resource = [
          "arn:${var.aws_partition}:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.namespace}/${var.stage}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "provisioner_ecs_task_parameter_store_secrets_read_access_attach" {
  role       = aws_iam_role.provisioner_ecs_execution_role.name
  policy_arn = aws_iam_policy.parameter_store_secrets_read_access[0].arn
}

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

resource "aws_iam_policy" "assume_provisioner_role_tagged" {
  name        = "${local.name_prefix}-provisioner-ar-tagged"
  description = "A policy allowing sts:AssumeRole on roles tagged with common-fate-aws-integration-provision-role"
  policy      = data.aws_iam_policy_document.assume_roles_policy_tagged.json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach_tagged" {
  role       = aws_iam_role.provisioner_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_provisioner_role_tagged.arn
}

resource "aws_ecs_task_definition" "provisioner_task" {
  family                   = "${local.name_prefix}-provisioner"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  execution_role_arn = aws_iam_role.provisioner_ecs_execution_role.arn
  task_role_arn      = aws_iam_role.provisioner_ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "provisioner-container",
    image = "${var.provisioner_image_repository}:${var.release_tag}",

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
        value = var.provisioner_service_client_id
      },
      {
        name  = "CF_CLIENT_SECRET"
        value = var.provisioner_service_client_secret
      },
      {
        name  = "CF_OIDC_ISSUER"
        value = var.auth_issuer
      },
      {
        name  = "CF_ASSUME_ROLE_EXTERNAL_ID"
        value = var.assume_role_external_id
      },
    ],


    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.provisioner_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "provisioner"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_provisioner_sg_v2.id]
    }
  }])

}

resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name = "${local.name_prefix}.internal"
  vpc  = var.vpc_id
}


resource "aws_service_discovery_service" "service" {
  name = "${local.name_prefix}-provisioner"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}



resource "aws_ecs_service" "provisioner_service" {
  name            = "${local.name_prefix}-provisioner"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.provisioner_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_task_count

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_provisioner_sg_v2.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service.arn
  }
}
