resource "aws_s3_bucket" "default_website_bucket" {
  bucket = "dolapo-website-bucket"

  tags = {
    Name = "default-website-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.default_website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default_website_bucket_encryption" {
  bucket = aws_s3_bucket.default_website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "default_index_html" {
  bucket = aws_s3_bucket.default_website_bucket.id
  key    = "index.html"
  source = "Website/index.html"
}

resource "aws_s3_object" "default_error_html" {
  bucket = aws_s3_bucket.default_website_bucket.id
  key    = "404.html"
  source = "Website/404.html"
}

resource "aws_s3_bucket_website_configuration" "default_website_configuration" {
  bucket = aws_s3_bucket.default_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "Website/error.html"
  }
}