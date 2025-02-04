###################################################################################################
# Security Group for ALB (Application Load Balancer)
#
# This security group ("alb_sg_prefix") is configured to allow ingress traffic on port 80 (HTTP)
# from two sources:
#   1. A prefix list, which represents a group of trusted IP ranges (e.g., CloudFront).
#   2. A specific IP provided via the variable "my_ip".
# Egress traffic is allowed to any destination.
###################################################################################################
resource "aws_security_group" "alb_sg_prefix" {
  name        = "alb-sg-prefix"                 # Name of the security group
  description = "Allow access to ALB service from CloudFront using prefix list"
  vpc_id      = aws_vpc.main_vpc.id             # VPC where this security group is created

  # Ingress rule: Allow HTTP traffic (port 80) from a defined prefix list.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = ["pl-3b927c52"]           # Prefix list ID (e.g., CloudFront or other trusted IP range)
  }

  # Ingress rule: Allow HTTP traffic (port 80) from a specific IP (defined by var.my_ip).
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [var.my_ip]               # Use a variable to specify an IP prefix or range
  }

  # Egress rule: Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                          # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]                 # Allow outbound traffic to any destination
  }

  tags = {
    Name        = "${var.environment_prod}-sg-alb"  # Tag for identifying the ALB security group in production
    Environment = "${var.environment_prod}"         # Tag for environment (e.g., production)
  }
}

###################################################################################################
# Security Group for ECS Service
#
# This security group ("ecs_service_sg") is configured to allow ingress traffic on port 80 (HTTP)
# from:
#   1. A specific IP provided via the variable "my_ip" (e.g., workstation or trusted network).
#   2. The ALB security group, ensuring that traffic from the ALB is allowed.
# Egress traffic is unrestricted.
###################################################################################################
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"                 # Name of the security group for ECS service
  description = "Allow access to ECS service from ALB and my IP using CIDR block"
  vpc_id      = aws_vpc.main_vpc.id              # VPC where the ECS service is deployed

  # Ingress rule: Allow HTTP traffic (port 80) from a specific IP or CIDR block.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]                    # Allow traffic from the IP range defined in var.my_ip
  }

  # Ingress rule: Allow HTTP traffic (port 80) from the ALB security group.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg_prefix.id]  # Allow traffic from the ALB SG by referencing its ID
  }

  # Egress rule: Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                          # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]                 # Allow outbound traffic to any destination
  }

  tags = {
    Name        = "${var.environment_prod}-sg-ecs"  # Tag for identifying the ECS service security group in production
    Environment = "${var.environment_prod}"         # Tag for environment (e.g., production)
  }
}
