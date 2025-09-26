# Configure the Terraform AWS Provider, version 6.14.2 or higher for ODB resources
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.14.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region              = local.location.region
  shared_config_files = local.shared_config_files
  profile             = local.profile
} 
