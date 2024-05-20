variable "licence_key" {
  description = "The Common Fate licence key."
  type        = string
  nullable    = true
  default     = null
}

variable "load_balancer_domain" {
  description = "The Common Fate ALB domain"
  type        = string
}
