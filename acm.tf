resource "aws_acm_certificate" "default_certificate" {
  domain_name       = "dolapoadeeyocv.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.dolapoadeeyocv.com"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "default-certificate"
  }

}
