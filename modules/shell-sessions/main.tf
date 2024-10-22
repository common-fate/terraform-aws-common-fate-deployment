resource "aws_s3_bucket" "proxy_shell_session_logs" {
  bucket = "${var.namespace}-${var.stage}-proxy_shell_session_logs"

}

resource "aws_s3_bucket_cors_configuration" "shell_logs_cors_policy" {
  bucket = aws_s3_bucket.proxy_shell_session_logs.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = []

  }
}

resource "aws_iam_policy" "shell_logs_s3_write_access" {
  name        = "${var.namespace}-${var.stage}-control-plane-shell-logs-s3-write"
  description = "Allows control plane to get and put objects into the shell session s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    // include only the secrets that are configured
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = [
        "${aws_s3_bucket.proxy_shell_session_logs.arn}/*",
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "control_plane_ecs_task_parameter_store_secrets_write_access_attach" {
  role       = var.control_plane_ecs_task_role_name
  policy_arn = aws_iam_policy.shell_logs_s3_write_access.arn
}
