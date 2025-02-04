data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json

  tags = {
    Name        = "${var.environment_prod}-ecr-iam-role-ecs"
    Environment = "${var.environment_prod}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-incident-handler-role"
  assume_role_policy = file("assume_lambda_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda-incident-handler-policy"
  role   = aws_iam_role.lambda_role.id
  policy = file("lambda_policy.json")
}

