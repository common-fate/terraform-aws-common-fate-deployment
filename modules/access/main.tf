resource "aws_security_group" "ecs_access_handler_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming HTTP requests from anywhere
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-ecs-access-handler-sg"
  }
}

resource "aws_cloudwatch_log_group" "access_handler_log_group" {
  name              = "${var.namespace}-${var.stage}-access_handler-lg"
  retention_in_days = 14 # You can adjust this based on your retention needs.
}



resource "aws_iam_role" "access_handler_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-access-handler-ecs-execution-role"
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
resource "aws_iam_role_policy_attachment" "access_handler_ecs_execution_role_policy_attach" {
  role       = aws_iam_role.access_handler_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



# TASK ROLE
resource "aws_iam_role" "access_handler_ecs_task_role" {
  name = "${var.namespace}-${var.stage}-access-handler-ecs-task-role"
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
  name        = "${var.namespace}-${var.stage}-ah-eventbus-put-events"
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
  role       = aws_iam_role.access_handler_ecs_task_role.name
  policy_arn = aws_iam_policy.eventbus_put_events.arn
}
resource "aws_ecs_task_definition" "access_handler_task" {
  family                   = "${var.namespace}-${var.stage}-access-handler-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.access_handler_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.access_handler_ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "access-handler-container",
    image = "commonfate/common-fate-cloud-access-handler:${var.release_tag}",

    memory = 256,
    portMappings = [{
      containerPort = 9090,
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
        name  = "CF_AUTHZ_URL",
        value = var.authz_domain
      },
      {
        name  = "CF_OIDC_TRUSTED_ISSUER_COGNITO",
        value = var.auth_issuer
      },
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
      securityGroupIds = [aws_security_group.ecs_access_handler_sg.id]
    }
  }])
}

resource "aws_lb_target_group" "access_handler_tg" {
  name        = "${var.namespace}-${var.stage}-ah-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled = true
    path    = "/health"
  }
  tags = {
    Name = "${var.namespace}-${var.stage}-access-handler-tg"
  }
}

resource "aws_ecs_service" "access_handler_service" {
  name            = "${var.namespace}-${var.stage}-access_handler-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.access_handler_task.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_access_handler_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.access_handler_tg.arn
    container_name   = "access-handler-container"
    container_port   = 9090
  }
}

resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.access_handler_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.access_handler_domain, "https://", "")]
    }
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-access-handler-rule"
  }
}
