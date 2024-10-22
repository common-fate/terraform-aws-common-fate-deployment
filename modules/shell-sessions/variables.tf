variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Defines the stage of the deployment (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}


variable "control_plane_ecs_task_role_name" {
  description = "Control plane task role name."
  type        = string
}

variable "proxy_shell_session_s3_bucket_arn" {
  description = "proxy shell session logs s3 bucket arn."
  type        = string
}
