# --------------------------------------------------------------------------
# Terraform Configuration Block
#
# This block configures the backend for storing Terraform state in S3,
# along with the state locking mechanism via a DynamoDB table.
# It also specifies the required providers for the project.
# --------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket         = "dolapo-prod-bucket"                # S3 bucket to store the Terraform state file
    dynamodb_table = "state-lock"                        # DynamoDB table used for state locking to prevent concurrent changes
    key            = "terraform/state/terraform.tfstate" # S3 object key for the state file
    region         = "us-east-1"                         # AWS region where the S3 bucket and DynamoDB table are located
    encrypt        = true                                # Encrypt the state file at rest for security
  }
  required_providers {
    aws = {
      source = "hashicorp/aws" # Specifies that the AWS provider will be sourced from HashiCorp's registry
    }
  }
}

# --------------------------------------------------------------------------
# AWS Provider Configuration
#
# This block configures the AWS provider with the desired region.
# All AWS resources in this configuration will be created in "us-east-1".
# --------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1" # AWS region for resource creation
}
