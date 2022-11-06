resource "aws_kms_key" "ecr_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for ECR Image Encryption"
  enable_key_rotation      = true
}

resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  tags                 = var.tags
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_encryption_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
