####################################################################################################
# Data Source: AWS Route 53 Hosted Zone
#
# This data source fetches information about a public Route 53 hosted zone for the domain
# "dolapoadeeyocv.com". The trailing dot in the domain name is required by Route 53.
####################################################################################################
data "aws_route53_zone" "default_zone" {
  name         = "dolapoadeeyocv.com."  # Fully qualified domain name with a trailing dot
  private_zone = false                 # Indicates that this is a public hosted zone, not private
}

