resource "aws_acm_certificate" "default_certificate" {
  domain_name       = "dolapoadeeyocv.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.dolapoadeeyocv.com",
    "app.dolapoadeeyocv.com"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment_prod}-certificate"
    Environment = "${var.environment_prod}"
  }

}
