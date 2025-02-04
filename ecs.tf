####################################################################################################
# ECS Cluster
#
# This resource creates an ECS cluster named "app-cluster" which is used to run container tasks.
# The cluster is tagged with environment information for easier identification and management.
####################################################################################################
resource "aws_ecs_cluster" "app" {
  name = "app-cluster"  # Name of the ECS cluster

  tags = {
    Name        = "${var.environment_prod}-ecs-cluster"  # Tag the cluster with the environment name
    Environment = "${var.environment_prod}"              # Additional environment tag (e.g., production)
  }
}

####################################################################################################
# ECS Task Definition for snake-app
#
# This resource defines the task definition for the "snake-app" containerized application.
# It specifies the required Fargate launch type, networking mode, CPU, and memory requirements.
# Container definitions are loaded from an external JSON file ("snake-app.json").
####################################################################################################
resource "aws_ecs_task_definition" "app" {
  family                   = "snake-app"              # Task family name for grouping related task definitions
  network_mode             = "awsvpc"                 # Use awsvpc mode to enable Fargate networking
  requires_compatibilities = ["FARGATE"]              # Specify that this task definition is for Fargate
  cpu                      = "256"                    # Allocate 256 CPU units (0.25 vCPU)
  memory                   = "512"                    # Allocate 512 MB of memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn  # IAM role that grants permissions for ECS to pull container images and publish logs
  container_definitions    = file("snake-app.json")   # Load container configuration from an external JSON file

  tags = {
    Name        = "${var.environment_prod}-ecs-task-def-snake-app"  # Tag for identifying the task definition
    Environment = "${var.environment_prod}"                         # Environment tag
  }
}

####################################################################################################
# ECS Service for snake-app
#
# This resource creates an ECS service to run and manage the "snake-app" tasks in the ECS cluster.
# It specifies a desired count of 1 task, uses Fargate launch type, and integrates with an ALB target group.
# The network configuration uses multiple subnets and a specific security group.
####################################################################################################
resource "aws_ecs_service" "app_service" {
  name            = "app-service"  # Name of the ECS service
  cluster         = aws_ecs_cluster.app.id  # Reference to the ECS cluster where tasks will run
  task_definition = aws_ecs_task_definition.app.arn  # Use the task definition created above
  desired_count   = 1             # Desired number of running tasks
  launch_type     = "FARGATE"     # Use Fargate launch type for serverless container management

  # Network configuration for the service tasks
  network_configuration {
    subnets          = [aws_subnet.main_subnet.id, aws_subnet.main_subnet_2.id]  # Subnets where tasks will be launched
    security_groups  = [aws_security_group.ecs_service_sg.id]  # Security group that controls inbound/outbound traffic for tasks
    assign_public_ip = true          # Assign public IP addresses to tasks (required if tasks must be publicly accessible)
  }

  # Load balancer configuration for the ECS service.
  # This configures the service to register tasks with the specified target group.
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn  # The target group to register ECS tasks with
    container_name   = "snake-app"           # The name of the container within the task definition
    container_port   = 80                    # The port on which the container listens
  }

  tags = {
    Name        = "${var.environment_prod}-ecs-snake-app"  # Tag for identifying the service
    Environment = "${var.environment_prod}"                # Environment tag
  }
}
