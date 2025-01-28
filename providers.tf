terraform {
  backend "s3" {
    bucket         = "dolapo-prod-bucket"
    dynamodb_table = "state-lock"
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}