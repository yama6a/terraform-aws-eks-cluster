data "aws_caller_identity" "current_account" {}

resource "aws_kms_alias" "s3_event_archive_encryption_key_alias" {
  name          = "alias/s3_event_archive_encryption_key"
  target_key_id = aws_kms_key.s3_event_archive_encryption_key.key_id
}

resource "aws_kms_key" "s3_event_archive_encryption_key" {
  tags                     = var.tags
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for S3 Event Archive encryption"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  policy                   = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        Effect = "Allow"
        "Principal" : {
          "AWS" : aws_iam_role.firehose_role.arn
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "event_archive" {
  bucket        = "${replace(var.project_name, "_", "-")}-event-archive"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "infrequent_access" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    id     = "event-archive-infrequent-access"
    status = "Enabled"
    transition {
      days          = 7
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_acl" "private_bucket_acl" {
  bucket = aws_s3_bucket.event_archive.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    # makes KMS encryption cheaper: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_event_archive_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
