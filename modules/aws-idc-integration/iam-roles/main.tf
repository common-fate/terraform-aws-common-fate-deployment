
locals {
  trusted_principals = compact([var.common_fate_aws_account_id, var.common_fate_aws_reader_role_arn, var.common_fate_aws_provisioner_role_arn])
}

# This policy allows the trusted principlas if one or more are specified else explicit deny
data "aws_iam_policy_document" "assume_roles_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = length(local.trusted_principals) > 0 ? "Allow" : "Deny"

    principals {
      type        = length(local.trusted_principals) > 0 ? "AWS" : "*"
      identifiers = length(local.trusted_principals) > 0 ? local.trusted_principals : ["*"]
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
  name               = "${var.namespace}-${var.stage}-idc-reader-role"
  description        = "A role used by Common Fate to read AWS IDC resources"
  assume_role_policy = data.aws_iam_policy_document.assume_roles_policy.json
  tags = {
    "common-fate-aws-integration-read-role" = "true"
  }
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
          "sso:ListAccountsForProvisionedPermissionSet"

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
  name               = "${var.namespace}-${var.stage}-idc-provisioner-role"
  description        = "A role used by Common Fate to provision access in AWS IDC"
  assume_role_policy = data.aws_iam_policy_document.assume_roles_policy.json
  tags = {
    "common-fate-aws-integration-provision-role" = "true"
  }
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
        # this statement is taken from the AWSSSOServiceRolePolicy managed policy
        "Sid" : "IAMSAMLProviderUpdateAction",
        "Effect" : "Allow",
        "Action" : [
          "iam:UpdateSAMLProvider"
        ],
        "Resource" : [
          "arn:aws:iam::*:saml-provider/AWSSSO_*"
        ]
      },
      {
        # this statement is taken from the AWSSSOServiceRolePolicy managed policy
        "Sid" : "IAMSAMLProviderCleanupActions",
        "Effect" : "Allow",
        "Action" : [
          # "iam:DeleteSAMLProvider", - removed here out of an abundance of caution, shouldn't be required for provisioning JIT access to the management account.
          "iam:GetSAMLProvider"
        ],
        "Resource" : [
          "arn:aws:iam::*:saml-provider/AWSSSO_*"
        ]
      },
      {
        # this statement is taken from the AWSSSOServiceRolePolicy managed policy
        "Sid" : "IAMRoleCleanupActions",
        "Effect" : "Allow",
        "Action" : [
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ],
        "Resource" : [
          "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*"
        ]
      },
      {
        "Sid" : "AssignManagementAccountIDC",
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:UpdateRoleDescription",
          "iam:UpdateAssumeRolePolicy",
          "iam:PutRolePermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary"
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


// an optional additional policy allowing IAM Identity Center group management
resource "aws_iam_policy" "idc_provision_group_membership" {
  count       = var.permit_group_assignment ? 1 : 0
  name        = "${var.namespace}-${var.stage}-idc-provision-groups"
  description = "Allows Common Fate to provision access to AWS IAM Identity Center groups"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AssignGroups",
        "Effect" : "Allow",
        "Action" : [
          "identitystore:CreateGroupMembership",
          "identitystore:DeleteGroupMembership",
          "identitystore:ListGroupMembershipsForMember",
          "identitystore:IsMemberInGroups",
          "identitystore:ListGroupMemberships"
        ],
        "Resource" : "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "idc_provision_idc_provision_group_membership_role_policy_attach" {
  count      = var.permit_group_assignment ? 1 : 0
  role       = aws_iam_role.provision_role.name
  policy_arn = aws_iam_policy.idc_provision_group_membership[0].arn
}


// an optional additional policy allowing management of permission sets
resource "aws_iam_policy" "idc_provision_permission_sets" {
  count       = var.permit_provision_permission_sets ? 1 : 0
  name        = "${var.namespace}-${var.stage}-idc-provision-permission-sets"
  description = "Allows Common Fate to create and delete permission sets"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CreatePermissionSet",
        "Effect" : "Allow",
        "Action" : [
          "sso:CreatePermissionSet",
          "sso:PutInlinePolicyToPermissionSet",
          "sso:DeletePermissionSet",
          "sso:TagResource"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ReadIDC",
        "Effect" : "Allow",
        "Action" : [
          "sso:DescribePermissionSet",
          "sso:ListAccountAssignments",
          "sso:ListPermissionSets",
          "sso:ListTagsForResource",
          "sso:ListAccountsForProvisionedPermissionSet"
        ],
        "Resource" : "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "idc_provision_permission_sets_policy_attach" {
  count      = var.permit_provision_permission_sets ? 1 : 0
  role       = aws_iam_role.provision_role.name
  policy_arn = aws_iam_policy.idc_provision_permission_sets[0].arn
}
