
resource "aws_iam_role" "read_role" {
  name        = "${var.namespace}-${var.stage}-idc-reader-role"
  description = "A role used by Common Fate to read AWS IDC resources"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = var.common_fate_aws_reader_role_arn
        }
      }
    ]
  })
}

resource "aws_iam_policy" "idc_read" {
  name        = "${var.namespace}-${var.stage}-idc-read"
  description = "Allows Common Fate to read resources from IDC"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ReadIDC",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetRole",
          "iam:GetSAMLProvider",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "identitystore:ListUsers",
          "identitystore:ListGroups",
          "identitystore:ListGroupMemberships",
          "organizations:DescribeAccount",
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListAccountsForParent",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListRoots",
          "organizations:ListTagsForResource",
          "sso:DescribePermissionSet",
          "sso:ListAccountAssignments",
          "sso:ListPermissionSets",
          "sso:ListTagsForResource",

        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_role_policy_attach" {
  role       = aws_iam_role.read_role.name
  policy_arn = aws_iam_policy.idc_read.arn
}

resource "aws_iam_role" "provision_role" {
  name        = "${var.namespace}-${var.stage}-idc-provisioner-role"
  description = "A role used by Common Fate to provision access in AWS IDC"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = var.common_fate_aws_provisioner_role_arn
        }
      }
    ]
  })
}

resource "aws_iam_policy" "idc_provision" {
  name        = "${var.namespace}-${var.stage}-idc-provision"
  description = "Allows Common Fate to provision access in AWS IDC"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AssignIDC",
        "Effect" : "Allow",
        "Action" : [
          "iam:UpdateSAMLProvider",
          "sso:CreateAccountAssignment",
          "sso:DeleteAccountAssignment",
          "sso:DescribeAccountAssignmentCreationStatus",
          "sso:DescribeAccountAssignmentDeletionStatus",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "provision_role_policy_attach" {
  role       = aws_iam_role.provision_role.name
  policy_arn = aws_iam_policy.idc_provision.arn
}

// an optional additional policy allowing management account access
resource "aws_iam_policy" "idc_provision_management_account" {
  count       = var.permit_management_account_assignments ? 1 : 0
  name        = "${var.namespace}-${var.stage}-idc-provision-management_account"
  description = "Allows Common Fate to provision access in AWS IDC to the organization management account"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AssignManagementAccountIDC",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
        ],
        "Resource" : "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*",
        "Condition" : {
          "StringEquals" : { // note that an $$ escape is used here so that terraform doesn't try to interpolate this string
            "aws:PrincipalOrgMasterAccountId" : "$${aws:PrincipalAccount}"
          }
        }
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "idc_provision_management_account_role_policy_attach" {
  count      = var.permit_management_account_assignments ? 1 : 0
  role       = aws_iam_role.provision_role.name
  policy_arn = aws_iam_policy.idc_provision_management_account[0].arn
}


