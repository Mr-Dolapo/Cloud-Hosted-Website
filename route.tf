###################################################################################################
# AWS Route Table
#
# This resource creates a route table for the specified VPC.
# The route table is tagged with the production environment information.
###################################################################################################
resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.main_vpc.id  # Associate the route table with the main VPC

  tags = {
    Name        = "${var.environment_prod}-route-table"  # Name tag for easier identification
    Environment = "${var.environment_prod}"              # Tag indicating the environment (e.g., production)
  }
}

###################################################################################################
# Default Route
#
# This resource creates a route in the route table to direct all outbound traffic (0.0.0.0/0)
# to the Internet Gateway, enabling internet access for the resources in the subnets.
###################################################################################################
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.default_route_table.id   # The route table to which this route will be added
  destination_cidr_block = "0.0.0.0/0"                              # Destination for all IPv4 traffic
  gateway_id             = aws_internet_gateway.igw.id              # Route traffic to the internet gateway
}

###################################################################################################
# Route Table Association for Subnet 1
#
# This resource associates the main subnet with the default route table.
###################################################################################################
resource "aws_route_table_association" "default_association" {
  subnet_id      = aws_subnet.main_subnet.id                       # The subnet to associate with the route table
  route_table_id = aws_route_table.default_route_table.id          # The route table to be associated
}

###################################################################################################
# Route Table Association for Subnet 2
#
# This resource associates a secondary subnet with the default route table.
###################################################################################################
resource "aws_route_table_association" "default_association_2" {
  subnet_id      = aws_subnet.main_subnet_2.id                     # The second subnet to associate with the route table
  route_table_id = aws_route_table.default_route_table.id          # The same route table used for all subnets
}
