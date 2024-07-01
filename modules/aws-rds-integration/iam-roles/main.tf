


# This policy allows the trusted principlas if one or more are specified else explicit deny
data "aws_iam_policy_document" "assume_roles_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.common_fate_aws_account_id]
    }


    # Optionally apply the external ID to the policy if it is supplied
    dynamic "condition" {
      for_each = var.assume_role_external_id != "" ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.assume_role_external_id]
      }
    }
  }
}
resource "aws_iam_role" "read_role" {
  name               = "${var.namespace}-${var.stage}-ecs-task-reader-role"
  description        = "A role used by Common Fate to read task IDs in an ECS cluster"
  assume_role_policy = data.aws_iam_policy_document.assume_roles_policy.json
  tags = {
    // this role is currently only used by the provisioner
    "common-fate-aws-integration-provision-role" = "true"
  }
}

resource "aws_iam_policy" "ecs_read" {
  name        = "${var.namespace}-${var.stage}-ecs-task-read"
  description = "Allows Common Fate to read task IDs in an ECS cluster"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ReadECS",
        "Effect" : "Allow",
        "Action" : [
          "ecs:ListTasks",
          "ecs:DescribeTasks",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_role_policy_attach" {
  role       = aws_iam_role.read_role.name
  policy_arn = aws_iam_policy.ecs_read.arn
}

