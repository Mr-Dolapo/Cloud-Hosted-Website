####################################################################################################
# Data Source: ECS Task Execution Role Policy Document
#
# This data source generates an IAM policy document that defines the trust relationship for the ECS 
# tasks execution role. It allows ECS tasks (from the service "ecs-tasks.amazonaws.com") to assume the role.
####################################################################################################
data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]  # Action to allow role assumption

    principals {
      type        = "Service"                      # The trusted entity type; in this case, an AWS service.
      identifiers = ["ecs-tasks.amazonaws.com"]    # ECS tasks are allowed to assume the role.
    }
  }
}

####################################################################################################
# ECS Task Execution Role
#
# This resource creates an IAM role for ECS task execution. The role uses the trust policy defined 
# in the data source above. This role is used by ECS tasks to obtain permissions for pulling container 
# images, publishing logs, etc.
####################################################################################################
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"                                # Name of the role
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json
  # The JSON representation of the trust policy that allows ECS tasks to assume this role.

  tags = {
    Name        = "${var.environment_prod}-ecr-iam-role-ecs"              # Tag for identifying the role in production
    Environment = "${var.environment_prod}"                               # Environment tag (e.g., production)
  }
}

####################################################################################################
# Attach Amazon ECS Task Execution Role Policy
#
# This resource attaches the AWS-managed policy "AmazonECSTaskExecutionRolePolicy" to the ECS task 
# execution role. This policy grants necessary permissions such as pulling container images from ECR 
# and writing logs to CloudWatch.
####################################################################################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name  # Attach the policy to the ECS task execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  # AWS-managed policy providing required permissions for ECS task execution.
}

####################################################################################################
# Lambda Execution Role
#
# This resource creates an IAM role for your Lambda function ("lambda-incident-handler-role").
# The trust policy is loaded from an external JSON file ("assume_lambda_role_policy.json"),
# which defines which entities (e.g., AWS Lambda) are allowed to assume this role.
####################################################################################################
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-incident-handler-role"         # Name of the Lambda execution role
  assume_role_policy = file("assume_lambda_role_policy.json")   # Load the trust policy from an external file

  # Tags for identification and environment grouping
  tags = {
    Name        = "${var.environment_prod}-lambda-role"  # Note: Adjust tag name if necessary to reflect Lambda role
    Environment = "${var.environment_prod}"
  }
}

####################################################################################################
# Lambda Inline Policy
#
# This resource attaches an inline policy to the Lambda execution role.
# The policy document is loaded from an external JSON file ("lambda_policy.json") using the file() function.
####################################################################################################
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda-incident-handler-policy"  # Name of the inline policy
  role   = aws_iam_role.lambda_role.id         # The Lambda execution role to attach the policy to
  policy = file("lambda_policy.json")          # Load the policy document from an external file
}
