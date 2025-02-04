###################################################################################################
# EventBridge Rule to Trigger Lambda from ECS Events
#
# This resource creates an EventBridge rule that listens for ECS task state changes.
# It filters events so that when an ECS task's lastStatus is "STOPPED", the rule is triggered.
###################################################################################################
resource "aws_cloudwatch_event_rule" "ecs_to_lambda" {
  name        = "ecs-to-lambda-trigger"                     # Name of the EventBridge rule
  description = "Trigger Lambda on ECS Task STOPPED events" # Descriptive text for clarity

  # Event pattern to match ECS events where a task has stopped.
  # This pattern matches events from the source "aws.ecs" with a detail-type of "ECS Task State Change"
  # and only triggers when the "lastStatus" field in the event detail is "STOPPED".
  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail-type" : ["ECS Task State Change"],
    "detail" : {
      "lastStatus" : ["STOPPED"]
    }
  })
}

###################################################################################################
# EventBridge Target for Lambda Function
#
# This resource sets the Lambda function as the target for the above EventBridge rule.
# When an event matching the rule's pattern occurs, EventBridge will invoke the Lambda function.
###################################################################################################
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ecs_to_lambda.name # Associate this target with the ECS-to-Lambda rule
  target_id = "ecsLambdaTarget"                            # A unique identifier for this target
  arn       = aws_lambda_function.incident_handler.arn     # The ARN of the Lambda function to be invoked
}
