resource "aws_ecs_cluster" "app" {
  name = "app-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "snake-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions    = file("snake-app.json")
}

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = [aws_subnet.main_subnet.id]
    security_groups  = [aws_security_group.ecs_service_sg_cidr.id, aws_security_group.ecs_service_sg_alb.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "snake-app"
    container_port   = 80
  }
}
