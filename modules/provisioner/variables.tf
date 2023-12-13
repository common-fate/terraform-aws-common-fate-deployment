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
variable "provisioner_type" {
  description = "The mode to run the provisioner, GCP."
  default     = "GCP"
  type        = string
}

variable "provisioner_role_arn" {
  description = "The Optional ARN of the IAM roles to assume which grants the provisioner access to a cloud environment or service."
  default     = ""
  type        = string
}

variable "provisioner_gcp_service_account_client_json_ps_arn" {
  description = "When deployed for GCP, and using service account credentials, this is arn of the secret credentials."
  default     = ""
  type        = string
}
variable "provisioner_gcp_workload_identity_conig_json" {
  description = "When deployed for GCP and using worklaod identity federation, this is the config file."
  default     = ""
  type        = string
}


variable "provisioner_aws_idc_region" {
  description = "When deployed for AWS, this is the AWS IDC Region."
  default     = ""
  type        = string
}

variable "provisioner_aws_idc_instance_arn" {
  description = "When deployed for AWS, this is the AWS Identity Center instance ARN."
  default     = ""
  type        = string
}
