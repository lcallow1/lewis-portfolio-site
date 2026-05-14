terraform {
    required_version = ">= 1.5"

    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }

    backend "s3" {
      bucket = "lewis-tfstate-c565nl"
      key = "lewis-portfolio-site/terraform.tfstate"
      region = "eu-west-2"
      dynamodb_table = "lewis-tfstate-lock"
      encrypt = true
    }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "site" {
  bucket = "lewis-portfolio-site-test-7sn4l"
}

