variable "bucket_name" {
    description = "The name of the S3 bucket to create for the static site."
    type        = string
  
}

variable "environment" {
    description = "Environment name - used for tagging. E.g. prod, staging, dev."
    type        = string
    default     = "prod"
  
}

variable "project" {
    description = "Project name - used for tagging."
    type        = string
    default = "lewis-portfolio-site"
  
}
