terraform {
    required_version = ">= 1.5"

    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "site" {
  bucket = "lewis-portfolio-site-test-7sn4l"
}

