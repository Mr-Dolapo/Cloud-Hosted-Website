####################################################################################################
# CREDENTIALS
#
# These variables store AWS credentials that might be used for provider authentication or
# other AWS resource operations. For security, these should be passed in securely (e.g., via
# environment variables or a secrets manager) and not hard-coded.
####################################################################################################
variable "access_key" {
  description = "AWS Access Key ID"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}

####################################################################################################
# ENVIRONMENT
#
# This variable defines the environment tag (e.g., production) used for naming and tagging
# resources, which helps in organizing and identifying resources.
####################################################################################################
variable "environment_prod" {
  description = "AWS Production Environment"
  type        = string
}

####################################################################################################
# HOST_DETAILS
#
# This variable is used to define your IP address for testing purposes. It is used in security
# groups and other network-related configurations to restrict access.
####################################################################################################
variable "my_ip" {
  description = "My IP address for testing"
  type        = string
}

####################################################################################################
# ROUTE 53 RECORDS
#
# These variables store the details for DNS records (specifically CNAME records) used for
# certificate validation and aliasing for your domain. They allow you to dynamically configure
# Route 53 records via Terraform.
####################################################################################################
variable "cname_name" {
  description = "The name of the CNAME record for certificate validation"
  type        = string
}

variable "cname_value" {
  description = "The value of the CNAME record for certificate validation"
  type        = string
}

variable "cname_name_www" {
  description = "The name of the CNAME record for www"
  type        = string
}

variable "cname_value_www" {
  description = "The value of the CNAME record for www"
  type        = string
}

variable "cname_name_app" {
  description = "The name of the CNAME record for app"
  type        = string
}

variable "cname_value_app" {
  description = "The value of the CNAME record for app"
  type        = string
}

####################################################################################################
# SERVICENOW_INSTANCE
#
# These variables hold the credentials and URL for your ServiceNow instance. They allow your
# Terraform configuration (and downstream Lambda functions) to connect securely to your ServiceNow API.
####################################################################################################
variable "service_now_instance" {
  description = "ServiceNow instance URL"
  type        = string
}

variable "service_now_username" {
  description = "ServiceNow instance username"
  type        = string
}

variable "service_now_password" {
  description = "ServiceNow instance password"
  type        = string
}

####################################################################################################
# JIRA
#
# These variables provide the configuration required to authenticate and interact with the
# Jira API. They include the API token, base URL, user email, and project key.
####################################################################################################
variable "jira_api_token" {
  description = "Jira API token for authentication"
  type        = string
}

variable "jira_base_url" {
  description = "Base URL for Jira (e.g., https://yourinstance.atlassian.net)"
  type        = string
}

variable "jira_email" {
  description = "Jira account email address"
  type        = string
}

variable "jira_project_key" {
  description = "Jira project key (e.g., DEV)"
  type        = string
}
