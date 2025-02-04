import os        # Provides functions to interact with the operating system (e.g., for environment variables)
import json      # Used to parse and generate JSON data
import requests  # Library for making HTTP requests to external APIs

# --------------------------------------------------------------------------------------------------
# Retrieve ServiceNow environment variables from Lambda environment settings.
# These variables are supplied externally (e.g., via Terraform or Lambda configuration) so that
# sensitive data is not hard-coded in your source code.
# --------------------------------------------------------------------------------------------------
SERVICENOW_INSTANCE_URL = os.environ.get("SERVICENOW_INSTANCE_URL")  # ServiceNow instance URL
SERVICENOW_USER = os.environ.get("SERVICENOW_USER")                  # ServiceNow username
SERVICENOW_PASS = os.environ.get("SERVICENOW_PASS")                  # ServiceNow password

# --------------------------------------------------------------------------------------------------
# Retrieve Jira environment variables from Lambda environment settings.
# These values are passed in externally for secure configuration.
# --------------------------------------------------------------------------------------------------
JIRA_API_TOKEN = os.environ.get("JIRA_API_TOKEN")      # Jira API token for authentication
JIRA_BASE_URL = os.environ.get("JIRA_BASE_URL")        # Base URL for Jira (e.g., "https://dolapoadeeyo.atlassian.net")
JIRA_EMAIL = os.environ.get("JIRA_EMAIL")              # Jira account email address
JIRA_PROJECT_KEY = os.environ.get("JIRA_PROJECT_KEY")  # Jira project key (e.g., "DEV")

# --------------------------------------------------------------------------------------------------
# Function: create_servicenow_incident
#
# Purpose:
#   Creates an incident in ServiceNow by sending an HTTP POST request to the ServiceNow API.
#
# Parameters:
#   - summary: A short description of the incident.
#   - description: Detailed information about the incident.
#
# Returns:
#   - A dictionary containing the incident's system ID ("sys_id") and human-friendly incident number ("number"),
#     e.g., {"sys_id": "02bec8b4...", "number": "INC0010018"}.
#   - Returns None if the incident creation fails.
# --------------------------------------------------------------------------------------------------
def create_servicenow_incident(summary, description):

    # Build the API URL for creating an incident, and request that the response include the "sys_id" and "number" fields.
    url = f"{SERVICENOW_INSTANCE_URL}/api/now/table/incident?sysparm_fields=sys_id,number"

    # Set headers to indicate that we are sending and accepting JSON data.
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    # Construct the JSON payload with necessary fields.
    # "caller_id" and "impact" should be adjusted based on your instance's configuration.
    payload = {
        "short_description": summary,           # Brief description of the incident.
        "description": description,             # Detailed information about the incident.
        "urgency": "2",                         # Sets the urgency level. PLANNED : Function to determine urgency level based on event parsed.
        "caller_id": "Dolapo",                  # Valid caller reference.
        "impact": "3"                           # Impact level as required by your ServiceNow instance. PLANNED : Function to determine impact level based on event parsed.
    }

    # Send a POST request to ServiceNow with HTTP Basic Authentication.
    response = requests.post(url, auth=(SERVICENOW_USER, SERVICENOW_PASS), headers=headers, json=payload)

    # If the response indicates success (HTTP 200 or 201), parse and return the relevant fields.
    if response.status_code in [200, 201]:
        result = response.json().get("result", {})
        return {"sys_id": result.get("sys_id"), "number": result.get("number")}
    else:
        # Log an error message with details for troubleshooting.
        print(f"Error creating incident in ServiceNow: {response.text}")
        return None

# --------------------------------------------------------------------------------------------------
# Function: create_jira_ticket
#
# Purpose:
#   Creates a Jira ticket by sending an HTTP POST request to the Jira Cloud REST API.
#
# Parameters:
#   - summary: A short summary of the Jira ticket.
#   - description: Detailed information about the ticket, including reference to a ServiceNow incident.
#
# Returns:
#   - A string representing the Jira issue key (e.g., "DEV-123") if successful.
#   - Returns None if ticket creation fails.
# --------------------------------------------------------------------------------------------------
def create_jira_ticket(summary, description):

    # Construct the API URL for creating a Jira issue.
    url = f"{JIRA_BASE_URL}/rest/api/3/issue"

    # Set headers to indicate JSON content and accepted response format.
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json"
    }

    # Build the description using Atlassian Document Format (ADF) to support rich formatting.
    adf_description = {
        "type": "doc",
        "version": 1,
        "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": description}]}
        ],
    }

    # Construct the payload with required fields for the Jira issue.
    payload = {
        "fields": {
            "project": {"key": JIRA_PROJECT_KEY},    # Associates the ticket with a specific Jira project.
            "summary": summary,                      # Short summary of the issue.
            "description": adf_description,          # Detailed description in ADF format.
            "issuetype": {"name": "Task"}            # Issue type, which can be changed as needed. PLANNED: Function to determine issue type.
        }
    }

    # Send the POST request to the Jira API using Basic Authentication (email and API token).
    response = requests.post(url, headers=headers, auth=(JIRA_EMAIL, JIRA_API_TOKEN), json=payload)

    # If the response indicates success, return the Jira issue key.
    if response.status_code in [200, 201]:
        result = response.json()
        return result.get("key")
    else:
        # Log an error message for debugging purposes.
        print(f"Error creating Jira ticket: {response.text}")
        return None

# --------------------------------------------------------------------------------------------------
# Function: lambda_handler
#
# Purpose:
#   Main entry point for the Lambda function.
#   Processes an incoming ECS event to create an incident in ServiceNow and a corresponding Jira ticket.
#
# Workflow:
#   1. Extracts key details from the ECS event payload.
#   2. Constructs a summary and detailed description using the ECS event information.
#   3. Calls create_servicenow_incident() to create a ServiceNow incident.
#   4. Enhances the description with ServiceNow incident info and calls create_jira_ticket() to create a Jira ticket.
#   5. Returns a JSON response containing both the incident information and Jira ticket key.
#
# Returns:
#   - A JSON response with a status code and a body containing the outcome.
# --------------------------------------------------------------------------------------------------
def lambda_handler(event, context):
    """
    Lambda handler that processes an ECS event, creates a ServiceNow incident, 
    and then creates a corresponding Jira ticket.
    """
    # Attempt to extract ECS event details from the event payload.
    try:
        ecs_detail = event.get("detail", {})  # Extract details from the event payload.
        task_id = ecs_detail.get("taskArn", "unknown")  # Get the task ARN; default to "unknown" if not present.
        last_status = ecs_detail.get("lastStatus", "unknown")  # Get the last status of the task.
        failure_reason = ecs_detail.get("stoppedReason", "N/A")  # Get the reason for stopping, if available.
    except Exception as e:
        # Log any exception that occurs during parsing.
        print("Error parsing ECS event:", e)
        task_id = "unknown"
        last_status = "unknown"
        failure_reason = "N/A"

    # Construct a summary and description for the incident using the extracted ECS details.
    summary = f"ECS Task Issue: {task_id}"  # Summarize using the task ID.
    description = (
        f"ECS event received.\n"  # Explain that the event is from ECS.
        f"Task ID: {task_id}\n"    # Include the task ID.
        f"Last Status: {last_status}\n"  # Include the last status.
        f"Failure Reason: {failure_reason}\n"  # Include the failure reason.
        f"Full event data: {json.dumps(event)}"  # Include the full event data for context.
    )

    # Create an incident in ServiceNow using the constructed summary and description.
    incident_info = create_servicenow_incident(summary, description)
    if not incident_info:
        # Return an error response if the incident creation fails.
        return {
            "statusCode": 500,
            "body": json.dumps("Failed to create incident in ServiceNow")
        }

    # Build a Jira ticket description that appends the ServiceNow incident information.
    jira_description = (
        f"{description}\n\nServiceNow Incident Info:\n"    # Original ECS details followed by incident info.
        f"Sys ID: {incident_info.get('sys_id')}\n"         # Include the ServiceNow sys_id.
        f"Number: {incident_info.get('number')}"           # Include the human-friendly incident number.
    )

    # Create a Jira ticket using the constructed summary and enhanced description.
    jira_ticket = create_jira_ticket(summary, jira_description)
    if not jira_ticket:
        # Return an error if the Jira ticket creation fails.
        return {
            "statusCode": 500,
            "body": json.dumps("Incident created in ServiceNow, but failed to create Jira ticket")
        }

    # Log success messages with incident and Jira ticket information.
    print("Successfully created incident with info:", incident_info)
    print("Successfully created Jira ticket:", jira_ticket)

    # Return a successful JSON response containing both the incident and Jira ticket info.
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Incident and Jira ticket created successfully",
            "incident_info": incident_info,
            "jira_ticket": jira_ticket,
        })
    }

# --------------------------------------------------------------------------------------------------
# Main execution block for local testing
#
# This block enables you to test the Lambda function locally by simulating an event.
# It only executes when the script is run directly (not when imported as a module).
# --------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    # Create a simulated ECS event for local testing of the Lambda function.
    # This event mimics an ECS Task State Change event where a task has stopped.
    test_event = {
        "version": "0",
        "id": "example-id",
        "detail-type": "ECS Task State Change",
        "source": "aws.ecs",
        "account": "123456789012",
        "time": "2025-02-01T12:00:00Z",
        "region": "us-east-1",
        "resources": [
            "arn:aws:ecs:us-east-1:123456789012:task/example-task-id"
        ],
        "detail": {
            "clusterArn": "arn:aws:ecs:us-east-1:123456789012:cluster/example-cluster",
            "taskArn": "arn:aws:ecs:us-east-1:123456789012:task/example-task-id",  # Simulated task ARN
            "lastStatus": "STOPPED",  # Simulated task status
            "stoppedReason": "Essential container in task exited"  # Simulated failure reason
        }
    }
    # Invoke the lambda_handler with the test event and print the output.
    result = lambda_handler(test_event, None)
    print("Lambda function result:", result)
