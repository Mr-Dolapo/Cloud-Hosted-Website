resource "aws_ecr_repository" "snake-app" {
  name                 = "snake-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-snake-app"
    Environment = "${var.environment_prod}"
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-app"
    Environment = "${var.environment_prod}"
  }
}

resource "aws_ecr_repository" "mongodb" {
  name                 = "mongodb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-mongodb"
    Environment = "${var.environment_prod}"
  }
}

resource "aws_ecr_repository" "mongo_express" {
  name                 = "mongo-express"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-mongo-express"
    Environment = "${var.environment_prod}"
  }
}