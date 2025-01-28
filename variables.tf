variable "access_key" {
  description = "AWS Access Key ID"
  type        = string
}
variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}
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

variable "my_ip" {
  description = "My IP address for testing"
  type = string
}