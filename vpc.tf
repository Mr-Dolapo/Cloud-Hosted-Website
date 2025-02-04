####################################################################################################
# AWS VPC - Main VPC
#
# This resource creates the main Virtual Private Cloud (VPC) for your environment.
# The VPC is configured with a CIDR block to define its IP address range and DNS support.
# It is tagged with environment information to facilitate identification and management.
####################################################################################################
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.100.0.0/16"  # The IP address range for the VPC.
  enable_dns_hostnames = true             # Enable DNS hostnames for instances in the VPC.
  enable_dns_support   = true             # Enable DNS resolution within the VPC.

  tags = {
    Name        = "${var.environment_prod}-vpc"  # Tag to identify the VPC by environment.
    Environment = "${var.environment_prod}"      # Tag to indicate the environment (e.g., production).
  }
}
