output "arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
}

output "id" {
  value       = aws_s3_bucket.this.id
  description = "Name of the bucket."
}
