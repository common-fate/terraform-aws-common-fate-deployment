######################################################
# Roles
######################################################

data "aws_iam_policy_document" "read_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.grant_principals_read_access
    }
  }
}

resource "aws_iam_role" "read_role" {
  name               = "${var.namespace}-${var.stage}-read-role-${var.name}"
  description        = "A role to be configured with a cloud service and granted read access to discover resources."
  assume_role_policy = data.aws_iam_policy_document.read_role_assume_role_policy.json
}

data "aws_iam_policy_document" "provision_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.grant_principals_provision_access
    }
  }
}

resource "aws_iam_role" "provision_role" {
  name               = "${var.namespace}-${var.stage}-provision-role-${var.name}"
  description        = "A role to be configured with a cloud service and  granted write access to granted and revoke access to resources."
  assume_role_policy = data.aws_iam_policy_document.provision_role_assume_role_policy.json
}

