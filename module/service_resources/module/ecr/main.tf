resource "aws_kms_alias" "ecr_encryption_key_alias" {
  name          = "alias/ecr_encryption_key"
  target_key_id = aws_kms_key.ecr_encryption_key.key_id
}

resource "aws_kms_key" "ecr_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for ECR Image Encryption"
  enable_key_rotation      = true
  deletion_window_in_days = 7
  tags                     = var.tags
}

resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  // this allows `terraform destroy` to delete the repository even if it contains images
  force_delete = true

  tags = var.tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_encryption_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "expiry_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images except latest 30"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
