######################################################
# Provisioner
######################################################

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
  name              = "${var.namespace}-${var.stage}-provisioner"
  retention_in_days = var.log_retention_in_days

}



resource "aws_iam_role" "provisioner_ecs_execution_role" {
  name        = "${var.namespace}-${var.stage}-provisioner-er"
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
  name        = "${var.namespace}-${var.stage}-provisioner-ecs-tr"
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


data "aws_iam_policy_document" "assume_roles_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.provisioner_role_arn]
  }
}
resource "aws_iam_policy" "assume_provisioner_role" {
  name        = "${var.namespace}-${var.stage}-access-handler-ar"
  description = "A policy allowing sts:AssumeRole on selected roles"
  policy      = data.aws_iam_policy_document.assume_roles_policy.json
}

resource "aws_iam_role_policy_attachment" "assume_roles_policy_attach" {
  role       = aws_iam_role.provisioner_ecs_task_role.name
  policy_arn = aws_iam_policy.assume_provisioner_role.arn
}

resource "aws_ecs_task_definition" "provisioner_task" {
  family                   = "${var.namespace}-${var.stage}-provisioner"
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
    environment = [
      {
        name  = "LOG_LEVEL"
        value = var.enable_verbose_logging ? "DEBUG" : "INFO"
      },
      {
        name  = "CF_PROVISIONER_ROLE_ARN"
        value = var.provisioner_role_arn
      }
    ],
    secrets = [

    ]

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
  name = "${var.namespace}.${var.stage}.internal"
  vpc  = var.vpc_id
}


resource "aws_service_discovery_service" "service" {
  name = "${var.namespace}-${var.stage}-provisioner"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}



resource "aws_ecs_service" "provisioner_service" {
  name            = "${var.namespace}-${var.stage}-provisioner"
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

