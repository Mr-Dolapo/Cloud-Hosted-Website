###################################################################################################
# Subnet in Availability Zone us-east-1a
#
# This resource creates a public subnet within the main VPC in the availability zone us-east-1a.
# The subnet is assigned a CIDR block of 10.100.1.0/24, and public IPs are mapped on launch.
###################################################################################################
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id      # Associate this subnet with the main VPC
  cidr_block              = "10.100.1.0/24"          # Define the subnet's CIDR block
  map_public_ip_on_launch = true                   # Automatically assign public IPs to instances on launch
  availability_zone       = "us-east-1a"           # Specify the availability zone for this subnet

  tags = {
    Name        = "${var.environment_prod}-subnet-use-1a"  # Tag name including environment information
    Environment = "${var.environment_prod}"              # Environment tag (e.g., production)
  }
}

###################################################################################################
# Subnet in Availability Zone us-east-1b
#
# This resource creates a public subnet within the main VPC in the availability zone us-east-1b.
# It uses a different CIDR block (10.100.2.0/24) to ensure network segmentation.
###################################################################################################
resource "aws_subnet" "main_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id      # Associate this subnet with the main VPC
  cidr_block              = "10.100.2.0/24"          # Define a separate CIDR block for this subnet
  map_public_ip_on_launch = true                   # Automatically assign public IPs to instances on launch
  availability_zone       = "us-east-1b"           # Specify the availability zone for this subnet

  tags = {
    Name        = "${var.environment_prod}-use-1b"         # Tag name using environment information
    Environment = "${var.environment_prod}"              # Environment tag for organization
  }
}
