####################################################################################################
# AWS Internet Gateway
#
# This resource creates an Internet Gateway for the specified VPC.
# An Internet Gateway allows communication between instances within the VPC and the internet.
# The resource is tagged for easier identification and management in the production environment.
####################################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id  # Associates the Internet Gateway with the main VPC

  tags = {
    Name        = "${var.environment_prod}-igw"  # Tag the gateway with a name that reflects the environment
    Environment = "${var.environment_prod}"      # Tag to indicate the environment (e.g., production)
  }
}
