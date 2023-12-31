######################################################
# Provisioner

# This module is designed to be configured for one or more provisioner types
# You can also deploy multiple instances of the module by setting the 'name' parameter
######################################################

// This is added so that we can use teh experimental optional() function on object variables
terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  aws_idc_config = var.aws_idc_config != null ? var.aws_idc_config : {}
  gcp_config     = var.gcp_config != null ? var.gcp_config : {}

  provisioner_types = compact([
    var.aws_idc_config != null ? "AWS_IDC" : "",
    var.gcp_config != null ? "GCP" : ""
  ])

  env_vars = [
    {
      name  = "CF_PROVISIONER_TYPES"
      value = join(",", local.provisioner_types)
    },
  ]

  # Add AWS and GCP specific environment variables if their configurations are provided
  aws_env_vars = var.aws_idc_config != null ? [
    {
      name  = "CF_AWS_ROLE_ARN"
      value = local.aws_idc_config.role_arn
    },
    {
      name  = "CF_AWS_IDC_REGION"
      value = local.aws_idc_config.idc_region
    },
    {
      name  = "CF_AWS_IDC_INSTANCE_ARN"
      value = local.aws_idc_config.idc_instance_arn
    }
  ] : []

  gcp_env_vars = var.gcp_config != null ? [
    {
      name  = "CF_GCP_WORKLOAD_IDENTITY_CONFIG_JSON"
      value = local.gcp_config.workload_identity_config_json
    }
  ] : []

  gcp_secrets = var.gcp_config != null && local.gcp_config.service_account_client_json_ps_arn != null ? [
    {
      name      = "CF_GCP_SERVICE_ACCOUNT_CREDENTIALS_JSON",
      valueFrom = local.gcp_config.service_account_client_json_ps_arn
    }
  ] : []

  grant_assume_roles = compact([
    var.aws_idc_config != null ? var.aws_idc_config.role_arn : ""
  ])
  grant_read_secret_arns = compact([
    var.gcp_config != null ? var.gcp_config.service_account_client_json_ps_arn : ""
  ])

  combined_env_vars = concat(local.env_vars, local.aws_env_vars, local.gcp_env_vars)
  combined_secrets  = concat(local.gcp_secrets)
  name_prefix       = join("-", compact([var.namespace, var.stage, var.name_prefix]))
}

# Use 'local.combined_env_vars' wherever you need to pass these environment variables

resource "aws_security_group" "ecs_provisioner_sg" {
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
    // Only allow incoming traffic from the access handler
    security_groups = [var.access_handler_sg_id]
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
      }
    ]
  })
}


resource "aws_iam_policy" "parameter_store_secrets_read_access" {
  count       = length(local.grant_read_secret_arns) > 0 ? 1 : 0
  name        = "${local.name_prefix}-provisioner-ps"
  description = "Allows read secret from parameter store"

  policy = jsonencode({
    Version = "2012-10-17",
    // include only the secrets that are configured
    Statement = [
      for arn in local.grant_read_secret_arns :
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

resource "aws_iam_role_policy_attachment" "provisioner_ecs_task_parameter_store_secrets_read_access_attach" {
  count      = length(local.grant_read_secret_arns) > 0 ? 1 : 0
  role       = aws_iam_role.provisioner_ecs_execution_role.name
  policy_arn = aws_iam_policy.parameter_store_secrets_read_access[0].arn
}

data "aws_iam_policy_document" "assume_roles_policy" {
  count = length(local.grant_assume_roles) == 0 ? 0 : 1
  statement {
    actions   = ["sts:AssumeRole"]
    resources = local.grant_assume_roles
  }
}
resource "aws_iam_policy" "assume_provisioner_role" {
  count       = length(local.grant_assume_roles) == 0 ? 0 : 1
  name        = "${local.name_prefix}-provisioner-ar"
  description = "A policy allowing sts:AssumeRole on selected roles"
  policy      = data.aws_iam_policy_document.assume_roles_policy[0].json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach" {
  count      = length(local.grant_assume_roles) == 0 ? 0 : 1
  role       = aws_iam_role.provisioner_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_provisioner_role[0].arn
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
    image = "commonfate/common-fate-cloud-provisioner:${var.release_tag}",

    portMappings = [{
      containerPort = 9999,
    }],
    environment = concat([
      {
        name  = "LOG_LEVEL"
        value = var.enable_verbose_logging ? "DEBUG" : "INFO"
      },
    ], local.combined_env_vars),

    secrets = local.combined_secrets


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
      securityGroupIds = [aws_security_group.ecs_provisioner_sg.id]
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

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_provisioner_sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service.arn
  }
}

