# Create an Application Load Balancer (ALB) for the application.
resource "aws_lb" "app_lb" {
  name               = "app-lb"                                                 # Name of the load balancer.
  internal           = false                                                    # Set to false for an Internet-facing ALB.
  load_balancer_type = "application"                                            # Specify an Application Load Balancer.
  security_groups    = [aws_security_group.alb_sg_prefix.id]                    # Security groups applied to the ALB.
  subnets            = [aws_subnet.main_subnet.id, aws_subnet.main_subnet_2.id] # Subnets where the ALB is deployed.

  enable_cross_zone_load_balancing = false # Disable cross-zone load balancing.

  tags = {
    Name        = "${var.environment_prod}-alb" # Tag for identification, using production environment variable.
    Environment = "${var.environment_prod}"     # Tag to indicate the environment.
  }
}

# Create a target group for ECS tasks, which will be used by the ALB to route traffic.
resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"  # Name of the target group.
  port        = 80                  # Port on which the targets receive traffic.
  protocol    = "HTTP"              # Protocol used for routing traffic.
  vpc_id      = aws_vpc.main_vpc.id # VPC where the target group is created.
  target_type = "ip"                # Targets are registered by IP address.

  # Configure the health check for the target group.
  health_check {
    path                = "/app/health" # URL path used to check target health.
    interval            = 30            # Interval (in seconds) between health checks.
    timeout             = 5             # Timeout (in seconds) for a health check response.
    healthy_threshold   = 2             # Number of consecutive successes before considering a target healthy.
    unhealthy_threshold = 2             # Number of consecutive failures before considering a target unhealthy.
  }

  tags = {
    Name        = "${var.environment_prod}-alb-target-group" # Tag for the target group.
    Environment = "${var.environment_prod}"                  # Environment tag.
  }
}

# Create a listener for the ALB that listens on port 80 (HTTP).
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn # Associate this listener with the ALB created above.
  port              = 80                # Listen on port 80.
  protocol          = "HTTP"            # Use HTTP protocol.

  default_action {
    type             = "forward"                                # Forward traffic to the specified target group.
    target_group_arn = aws_lb_target_group.ecs_target_group.arn # Target group where traffic is sent.
  }
}

# Create a listener rule to route traffic based on host header and path pattern conditions.
resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.http_listener.arn # The listener to which this rule applies.
  priority     = 100                               # Priority of the rule (lower number means higher priority).

  # Action: forward traffic to the ECS target group if conditions match.
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }

  # Condition: apply this rule for any path.
  condition {
    path_pattern {
      values = ["/*"] # Matches all paths.
    }
  }

  # Condition: apply this rule when the host header matches the specified domain.
  condition {
    host_header {
      values = ["app.dolapoadeeyocv.com"]
    }
  }
}
