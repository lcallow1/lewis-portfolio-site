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

output "acm_validation_records" {
  description = "DNS records to add in Cloudflare to validate the ACM certificate."
  value = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain name. Point your DNS CNAME at this."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  description = "The CloudFront distribution ID. Used for cache invalidations."
  value       = aws_cloudfront_distribution.site.id
}
