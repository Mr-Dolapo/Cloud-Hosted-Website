resource "aws_ecr_repository" "snake-app" {
  name                 = "snake-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "prod-ecr-app"
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "prod-ecr-app"
  }
}

resource "aws_ecr_repository" "mongodb" {
  name                 = "mongodb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "prod-ecr-mongodb"
  }
}

resource "aws_ecr_repository" "mongo_express" {
  name                 = "mongo-express"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "prod-ecr-mongo-express"
  }
}