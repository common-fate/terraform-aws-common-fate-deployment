locals {
  role_name = "${var.namespace}-${var.stage}-audit-role"
}

resource "aws_cloudformation_stack_set" "audit_roles" {
  name = "${var.namespace}-${var.stage}-audit-role-stack"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  parameters = {
    ExternalID        = var.assume_role_external_id
    CommonFateAccount = var.common_fate_aws_account_id
    RoleName          = local.role_name
  }

  template_body = file("${path.module}/audit-role.yaml")
  lifecycle {
    ignore_changes = [parameters.RoleName]
  }
}


resource "aws_cloudformation_stack_set_instance" "audit_role_stackset_instance" {
  deployment_targets {
    organizational_unit_ids = var.organizational_unit_ids
  }
  stack_set_name = aws_cloudformation_stack_set.audit_roles.name
}

