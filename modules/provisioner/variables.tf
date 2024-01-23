variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Determines the deployment stage (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}

variable "name_prefix" {
  description = "A unique identifier consisting of letters, numbers, and hyphens. can optionally be left empty when only deploying a signal instance of this module"
  type        = string
  default     = ""

  # validation {
  #   condition     = var.name_prefix != "" && can(regex("^[a-zA-Z0-9-]+$", var.name_prefix))
  #   error_message = "name_prefix should only contain letters, numbers, and hyphens"
  # }
}
variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.app_url))
    error_message = "The app_url must start with 'https://'."
  }
}

variable "vpc_id" {
  description = "Specifies the ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the subnet IDs for deployment."
  type        = list(string)
}


variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}


variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
  type        = string
}

variable "log_retention_in_days" {
  description = "Specifies the cloudwatch log retention period."
  default     = 365
  type        = number
}
variable "ecs_task_cpu" {
  description = "The amount of CPU to allocate for the ECS task. Specified in CPU units (1024 units = 1 vCPU)."
  type        = string
  default     = "256" # Example default, adjust as needed
}

variable "ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "512" # Example default, adjust as needed
}
variable "desired_task_count" {
  description = "The desired number of instances of the task to run."
  type        = number
  default     = 1
}
variable "enable_verbose_logging" {
  description = "Enables debug level verbose logging on ecs tasks"
  type        = bool
  default     = false
}


variable "access_handler_sg_id" {
  description = "The Access Handler security group ID which will be allowed to make API calls to this provisioner."
  type        = string
}

variable "provisioner_service_client_id" {
  description = "Specifies the client ID for the provisioner service."
  type        = string
}

variable "provisioner_service_client_secret" {
  description = "Specifies the client secret for the provisioner service."
  type        = string
  sensitive   = true
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}


variable "aws_idc_config" {
  description = <<EOF
  Configuration for AWS IDC. The following keys are expected:
  - role_arn: The ARN of the IAM role for the provisioner to assume which hass permissions to provision access in an AWS organization.
  - idc_region: The AWS IDC Region.
  - idc_instance_arn: The AWS Identity Center instance ARN.
  EOF
  type = object({
    role_arn         = string
    idc_region       = string
    idc_instance_arn = string
  })
  default = null
}

variable "gcp_config" {
  description = <<EOF
  Configuration for GCP. The following keys are expected:
  - service_account_client_json_ps_arn: (Optional) when using service account credentials, this is ARN of the secret credentials.
  - workload_identity_config_json: (Optional) using Workload Identity Federation, this is the config file.

  Either `workload_identity_config_json` or `service_account_client_json_ps_arn` must be provided (not both).
  EOF
  type = object({
    service_account_client_json_ps_arn = optional(string)
    workload_identity_config_json      = optional(string)
  })
  default = null
}


variable "entra_config" {
  description = <<EOF
  Configuration for GCP. The following keys are expected:
  - tenant_id: The Entra tenant ID.
  - client_id: The client ID for the Entra App Registration.
  - client_secret_secret_path: The SSM Parameter store secret path for the client secret for the Entra App Registration.
  EOF
  type = object({
    tenant_id                 = string
    client_id                 = string
    client_secret_secret_path = string
  })
  default = null
}


variable "aws_rds_config" {
  description = <<EOF
  Configuration for AWS RDS. The following keys are expected:
  - role_arn: The ARN of the IAM role for the provisioner to assume which hass permissions to provision access in an AWS organization.
  - idc_region: The AWS IDC Region.
  - idc_instance_arn: The AWS Identity Center instance ARN.
  - infra_role_name: The name of the IAM role which is deployed each each account containing databases.
  - should_provision_security_groups: (Optional) Whether or not the provisioner should attempt to provision security groups. Set this to true if you are not using pre deployed security groups.
  EOF
  type = object({
    idc_role_arn                     = string
    idc_region                       = string
    idc_instance_arn                 = string
    infra_role_name                  = string
    should_provision_security_groups = optional(bool)
  })
  default = null
}
