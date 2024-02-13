locals {
  role_name = "${var.namespace}-${var.stage}-audit-role"
}
resource "aws_cloudformation_stack_set" "audit_roles" {
  name = "${var.namespace}-${var.stage}-audit-role-stack"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }
  // deploy everything in parallel
  operation_preferences {
    max_concurrent_percentage = 100
    region_concurrency_type   = "PARALLEL"
  }
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  parameters = {
    ExternalID        = var.assume_role_external_id
    CommonFateAccount = var.common_fate_aws_account_id
    RoleName          = local.role_name
  }

  template_body = <<-EOT
AWSTemplateFormatVersion: "2010-09-09"
Description: "Deploys an IAM role allowing Common Fate to audit the AWS account"
Parameters:
  RoleName:
    Type: String
    Description: Name for the IAM role
    Default: common-fate-audit
  ExternalID:
    Type: String
    Description: The ExternalID to be used in the trust relationship
  CommonFateAccount:
    Type: String
    Description: The AWS account ID that your Common Fate deployment is running in

Metadata:
  CF::Template: AWSAudit
  CF::Version: 1

Resources:
  AuditRole:
    Type: "AWS::IAM::Role"
    Properties:
      RoleName: !Ref RoleName
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              AWS: !Sub "arn:aws:iam::$${CommonFateAccount}:root"
            Action: "sts:AssumeRole"
            Condition:
              StringEquals:
                "sts:ExternalId": !Ref ExternalID
      ManagedPolicyArns:
        - "arn:aws:iam::aws:policy/SecurityAudit"
      Tags:
        - Key: common-fate-aws-integration-read-role
          Value: "true"
  EOT
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

