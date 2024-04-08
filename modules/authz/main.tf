
######################################################
# Authz Task
######################################################
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs_authz_sg_v2" {
  name        = "${var.namespace}-${var.stage}-authz"
  description = "Common Fate Authz networking"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # // authz api
  ingress {
    from_port       = 5050
    to_port         = 5050
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  // graphql
  ingress {
    from_port       = 5051
    to_port         = 5051
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  // monitoring
  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  lifecycle {
    create_before_destroy = true
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

resource "aws_iam_policy" "dynamodb_write" {
  name        = "${var.namespace}-${var.stage}-authz-ddb"
  description = "Allows ECS tasks to write to dynamodb"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "DynamoDBIndexAndStreamAccess",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams"
        ],
        "Resource" : [
          "${var.dynamodb_table_arn}/index/*",
          "${var.dynamodb_table_arn}/stream/*"
        ]
      },
      {
        "Sid" : "DynamoDBTableAccess",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        "Resource" : var.dynamodb_table_arn
      },
      {
        "Sid" : "DynamoDBDescribeLimitsAccess",
        "Effect" : "Allow",
        "Action" : "dynamodb:DescribeLimits",
        "Resource" : [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })

}
resource "aws_iam_role_policy_attachment" "authz_dynamodb_write_attach" {
  role       = aws_iam_role.authz_ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_write.arn
}

resource "aws_iam_policy" "authz_eval_bucket" {
  name        = "${var.namespace}-${var.stage}-authz-eval-bucket"
  description = "Allows the Authz service to write to the authorization evaluation S3 bucket"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : ["${var.authz_eval_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eval_bucket_attach" {
  role       = aws_iam_role.authz_ecs_task_role.name
  policy_arn = aws_iam_policy.authz_eval_bucket.arn
}

resource "aws_iam_policy" "eventbus_put_events" {
  name        = "${var.namespace}-${var.stage}-authz-eb"
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

resource "aws_iam_role_policy_attachment" "eventbus_put_events_attach" {
  role       = aws_iam_role.authz_ecs_task_role.name
  policy_arn = aws_iam_policy.eventbus_put_events.arn
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
    image = "${var.authz_image_repository}:${var.release_tag}",

    portMappings = [
      {
        containerPort = 9090,
        name          = "monitoring"
      },
      {
        containerPort = 5050,
        name          = "grpc"
      },
      {
        containerPort = 5051,
        name          = "graphql"
      },
    ],
    environment = [
      {
        name  = "AUTHZ_DYNAMODB_TABLE"
        value = var.dynamodb_table_name
      },
      { name  = "CF_CORS_ALLOWED_ORIGINS"
        value = join(",", concat([var.app_url], var.additional_cors_allowed_origins))
      },
      {
        name  = "LOG_LEVEL"
        value = var.log_level
      },
      {
        name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
        value = var.oidc_trusted_issuer
      },
      {
        name  = "CF_OIDC_TERRAFORM_SERVICE_CLIENT_ID",
        value = var.oidc_terraform_client_id
      },
      {
        name  = "CF_OIDC_CONTROL_PLANE_SERVICE_CLIENT_ID",
        value = var.oidc_control_plane_client_id
      },
      {
        name  = "CF_OIDC_ACCESS_SERVICE_CLIENT_ID",
        value = var.oidc_access_handler_service_client_id
      },
      {
        name  = "CF_OIDC_PROVISIONER_SERVICE_CLIENT_ID",
        value = var.oidc_provisioner_service_client_id
      },
      {
        name  = "CF_EVAL_SINK_TYPE",
        value = "aws"
      },
      {
        name  = "CF_EVAL_SINK_AWS_EVENT_BRIDGE_ARN",
        value = var.eventbus_arn
      },
      {
        name  = "CF_EVAL_SINK_AWS_S3_BUCKET",
        value = var.authz_eval_bucket_name
      },
      {
        name  = "CF_OIDC_SLACK_SERVICE_CLIENT_ID",
        value = var.oidc_slack_service_client_id
      },
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
      securityGroupIds = [aws_security_group.ecs_authz_sg_v2.id]
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
    enabled  = true
    port     = 5050
    protocol = "HTTP"
    path     = "/commonfate.authz.v1alpha1.HealthService/HealthCheck"
    matcher  = "0"
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

resource "aws_service_discovery_http_namespace" "test" {
  name        = "cf-test-namespace"
  description = "test"
}

output "dicovery_arn" {
  value = aws_service_discovery_http_namespace.test.arn
}

resource "aws_ecs_service" "authz_service" {
  name            = "${var.namespace}-${var.stage}-authz"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.authz_task.arn
  launch_type     = "FARGATE"

  desired_count = var.desired_task_count

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.test.arn

    service {
      discovery_name = "authz-grpc"
      port_name      = "grpc"
      client_alias {
        dns_name = "authz-grpc"
        port     = 5050
      }
    }
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_authz_sg_v2.id]
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
