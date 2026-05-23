output "bucket_id" {
  description = "The name of the S3 bucket."
  value       = module.site.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.site.bucket_arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name - used as the CloudFront origin."
  value       = module.site.bucket_regional_domain_name
}
