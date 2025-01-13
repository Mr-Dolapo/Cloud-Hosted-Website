# Get the ACM certificate details
# data "aws_acm_certificate" "default_certificate" {
#   domain      = "dolapoadeeyocv.com"
#   most_recent = true
# statuses    = ["PENDING_VALIDATION", "ISSUED"]
# }

# data "aws_acm_certificate" "default_certificate_www" {
#   domain      = "www.dolapoadeeyocv.com"
#   most_recent = true
# statuses    = ["PENDING_VALIDATION", "ISSUED"]
# }

data "aws_route53_zone" "default_zone" {
  name         = "dolapoadeeyocv.com."
  private_zone = false
}


