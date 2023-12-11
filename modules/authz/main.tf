
######################################################
# Authz Task
######################################################

resource "aws_security_group" "ecs_authz_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // authz api
  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }
  // graphql
  ingress {
    from_port   = 5051
    to_port     = 5051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }

  // monitoring
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }


}

resource "aws_cloudwatch_log_group" "authz_log_group" {
  name              = "${var.namespace}-${var.stage}-authz"
  retention_in_days = var.log_retention_in_days
}



resource "aws_iam_role" "authz_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-authz-er"
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
resource "aws_iam_role_policy_attachment" "authz_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.authz_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# TASK ROLE
resource "aws_iam_role" "authz_ecs_task_role" {
  name        = "${var.namespace}-${var.stage}-authz-ecs-tr"
  description = "The task role assumed by the Authz task."
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

resource "aws_iam_policy" "dynamodb_write" {
  name        = "${var.namespace}-${var.stage}-authz-ddb"
  description = "Allows ECS tasks to write to dynamodb"

  // @TODO:SECURITY
  // revert these permissions
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "*",
          # "dynamodb:BatchGetItem",
          # "dynamodb:BatchWriteItem",
          # "dynamodb:ConditionCheckItem",
          # "dynamodb:PutItem",
          # "dynamodb:DescribeTable",
          # "dynamodb:DeleteItem",
          # "dynamodb:GetItem",
          # "dynamodb:Scan",
          # "dynamodb:Query",
          # "dynamodb:UpdateItem"
        ],
        "Resource" : "*", #var.dynamodb_table_arn
      }
    ]
  })

}
resource "aws_iam_role_policy_attachment" "authz_dynamodb_write_attach" {
  role       = aws_iam_role.authz_ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_write.arn
}

resource "aws_ecs_task_definition" "authz_task" {
  family                   = "${var.namespace}-${var.stage}-authz"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.authz_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.authz_ecs_task_role.arn
  container_definitions = jsonencode([{

    name  = "authz-container",
    image = "commonfate/common-fate-cloud-authz:${var.release_tag}",

    portMappings = [
      {
        containerPort = 9090,
      },
      {
        containerPort = 5050,
      },
      {
        containerPort = 5051,
      },
    ],
    environment = [
      {
        name  = "AUTHZ_DYNAMODB_TABLE"
        value = var.dynamodb_table_name
      },
      { name  = "CF_CORS_ALLOWED_ORIGINS"
        value = join(",", [var.app_url])
      },
      {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
        value = var.oidc_trusted_issuer
      },
      {
        name  = "CF_OIDC_TERRAFORM_CLIENT_ID",
        value = var.oidc_terraform_client_id
      }

    ],
    secrets = []

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.authz_log_group.name,
        "awslogs-region"        = var.aws_region,
        "awslogs-stream-prefix" = "authz"
      }
    },

    # Link to the security group
    linuxParameters = {
      securityGroupIds = [aws_security_group.ecs_authz_sg.id]
    }
  }])
}

resource "aws_lb_target_group" "grpc_tg" {
  name             = "${var.namespace}-${var.stage}-authz-grpc"
  port             = 5050
  protocol         = "HTTP"
  protocol_version = "GRPC"
  vpc_id           = var.vpc_id
  target_type      = "ip"

  health_check {
    enabled = true
    path    = "/commonfate.authz.v1alpha1.HealthService/HealthCheck"
    matcher = "0-99"
  }

}

resource "aws_lb_target_group" "graphql_tg" {
  name        = "${var.namespace}-${var.stage}-authz-graphql"
  port        = 5051
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/health" # Uses the monitoring API for healthcheck
    port    = 9090
  }
}

resource "aws_ecs_service" "authz_service" {
  name            = "${var.namespace}-${var.stage}-authz"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.authz_task.arn
  launch_type     = "FARGATE"

  desired_count = var.desired_task_count

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_authz_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grpc_tg.arn
    container_name   = "authz-container"
    container_port   = 5050
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.graphql_tg.arn
    container_name   = "authz-container"
    container_port   = 5051
  }
}

resource "aws_lb_listener_rule" "graph_service_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graphql_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.app_url, "https://", "")]
    }
  }
  condition {
    path_pattern {
      values = ["/graph*"]
    }
  }
}
resource "aws_lb_listener_rule" "grpc_service_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grpc_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.app_url, "https://", "")]
    }
  }
  condition {
    path_pattern {
      values = ["/commonfate.authz*", "/commonfate.entity*"]
    }
  }
}
