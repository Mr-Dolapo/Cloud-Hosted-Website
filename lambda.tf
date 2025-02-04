resource "aws_lambda_function" "incident_handler" {
  function_name = "incident_handler"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function_payload.zip"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      SERVICENOW_INSTANCE_URL = var.service_now_instance
      SERVICENOW_USER         = var.service_now_username
      SERVICENOW_PASS         = var.service_now_password
      JIRA_API_TOKEN          = var.jira_api_token
      JIRA_BASE_URL           = var.jira_base_url
      JIRA_EMAIL              = var.jira_email
      JIRA_PROJECT_KEY        = var.jira_project_key
    }
  }

  tags = {
    Name        = "${var.environment_prod}-lambda"
    Environment = "${var.environment_prod}"
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.incident_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_to_lambda.arn
}
