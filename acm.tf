resource "aws_acm_certificate" "default_certificate" {
  domain_name       = "dolapoadeeyocv.com"
  validation_method = "DNS"

  tags = {
    Name = "default_certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}
