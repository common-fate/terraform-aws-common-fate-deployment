locals {
  role_name = "${var.namespace}-${var.stage}-rds-provision-role"
}



resource "aws_cloudformation_stack_set" "rds_provision_roles" {
  name = "${var.namespace}-${var.stage}-rds-provision-role-stack"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  parameters = {
    ExternalID        = var.assume_role_external_id
    TrustedPrincipals = var.common_fate_aws_account_id
    RoleName          = local.role_name
  }

  template_body = <<-EOT
AWSTemplateFormatVersion: "2010-09-09"
Description: "Deploys an IAM role allowing Common Fate to provision access to an RDS instance in the AWS account"
Parameters:
  RoleName:
    Type: String
    Description: Name for the IAM role
    Default: common-fate-provision-rds
  ExternalID:
    Type: String
    Description: The ExternalID to be used in the trust relationship
  CommonFateAccount:
    Type: String
    Description: The AWS account ID that your Common Fate deployment is running in

Metadata:
  CF::Template: AWSRDSProvisioner
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
      Policies:
        - PolicyName: EC2RDSPermissions
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - ec2:AuthorizeSecurityGroupIngress
                  - ec2:CreateSecurityGroup
                  - ec2:CreateTags
                  - ec2:DescribeImages
                  - ec2:DescribeInstances
                  - ec2:DescribeRouteTables
                  - ec2:DescribeSecurityGroups
                  - ec2:DescribeSubnets
                  - ec2:RevokeSecurityGroupIngress
                  - ec2:RunInstances
                  - iam:AddRoleToInstanceProfile
                  - iam:AttachRolePolicy
                  - iam:CreateInstanceProfile
                  - iam:CreatePolicy
                  - iam:CreateRole
                  - iam:DeleteInstanceProfile
                  - iam:DeletePolicy
                  - iam:DeletePolicyVersion
                  - iam:DeleteRole
                  - iam:DetachRolePolicy
                  - iam:ListPolicyVersions
                  - iam:PassRole
                  - iam:RemoveRoleFromInstanceProfile
                  - iam:Tag*
                  - rds:DescribeDBInstances
                  - rds:ModifyDBInstance
                Resource: "*"
              - Effect: Allow
                Action:
                  - ec2:AssociateIamInstanceProfile
                  - ec2:DeleteSecurityGroup
                  - ec2:TerminateInstances
                Resource: "*"
                Condition:
                  StringEquals: #Only instances that are correctly tagged can be terminated
                    "aws:ResourceTag/common-fate-jit-rds-managed": "true"
      Tags:
        - Key: common-fate-aws-integration-provision-role
          Value: "true"

  EOT
  lifecycle {
    ignore_changes = [parameters.RoleName]
  }
}


resource "aws_cloudformation_stack_set_instance" "rds_provision_role_stackset_instance" {
  deployment_targets {
    organizational_unit_ids = var.organizational_unit_ids
  }
  stack_set_name = aws_cloudformation_stack_set.rds_provision_roles.name
}

