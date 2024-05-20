output "app_url" {
  value = "https://${local.app_domain}"
}

output "app_certificate_arn" {
  value = aws_acm_certificate.this.arn
}
