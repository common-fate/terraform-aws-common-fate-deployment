resource "aws_s3_bucket_cors_configuration" "main" {
  count  = var.cors_rules != null ? 1 : 0
  bucket = aws_s3_bucket.main.id


  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
      id              = lookup(cors_rule.value, "id", null)
    }
  }
}
