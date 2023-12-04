
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

  // api
  ingress {
    from_port   = 5050
    to_port     = 5050
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

  tags = {
    Name = "${var.namespace}-${var.stage}-ecs-authz-sg"
  }
}

resource "aws_cloudwatch_log_group" "authz_log_group" {
  name              = "${var.namespace}-${var.stage}-authz-lg"
  retention_in_days = 14
}



resource "aws_iam_role" "authz_ecs_execution_role" {
  name = "${var.namespace}-${var.stage}-authz-ecs-execution-role"
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



resource "aws_ecs_task_definition" "authz_task" {
  family                   = "${var.namespace}-${var.stage}-authz-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.authz_ecs_execution_role.arn

  container_definitions = jsonencode([{

    name  = "authz-container",
    image = "commonfate/common-fate-cloud-authz:${var.release_tag}",

    memory = 256,
    portMappings = [
      {
        containerPort = 9090,
      },
      {
        containerPort = 5050,
      },
    ],
    environment = [],
    secrets     = []

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

resource "aws_lb_target_group" "authz_tg" {
  name             = "${var.namespace}-${var.stage}-authz-tg"
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
  tags = {
    Name = "${var.namespace}-${var.stage}-authz-tg"
  }
}

resource "aws_ecs_service" "authz_service" {
  name            = "${var.namespace}-${var.stage}-authz-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.authz_task.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_authz_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.authz_tg.arn
    container_name   = "authz-container"
    container_port   = 5050
  }
}
resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.authz_tg.arn
  }

  condition {
    host_header {
      values = [replace(var.authz_domain, "https://", "")]
    }
  }

  tags = {
    Name = "${var.namespace}-${var.stage}-authz-rule"
  }
}
