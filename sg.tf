resource "aws_security_group" "ecs_service_sg_prefix" {
  name        = "ecs-service-sg-prefix"
  description = "Allow access to ECS service from CloudFront using prefix list"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    prefix_list_ids = ["pl-3b927c52"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ecs_service_sg_cidr" {
  name        = "ecs-service-sg-cidr"
  description = "Allow access to ECS service from my IP using CIDR block"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

