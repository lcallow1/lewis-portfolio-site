terraform {
  required_version = ">=1.5" # Terraform must be version 1.5 or more

  required_providers { # use the hashicorp/aws provider, version 5-point-anything, but not 6.x.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" { # Private Storage
    bucket         = "lewis-tfstate-c565nl"
    key            = "lewis-portfolio-site/terraform.tfstate"
    region         = "eu-west-2" # London
    dynamodb_table = "lewis-tfstate-lock"
    encrypt        = true #encrypts state at rest
  }
}

provider "aws" { # Provider + Region (London)
  region = "eu-west-2"
}

provider "aws" { #Secondary Provider for CloudFront
  alias  = "us_east_1"
  region = "us-east-1"

}

module "site" {
  source      = "./modules/static_site"
  bucket_name = var.bucket_name
}



