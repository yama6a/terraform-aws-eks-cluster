resource "aws_kms_key" "s3_event_archive_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for S3 Event Archive encryption"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  tags                     = var.tags
}

resource "aws_s3_bucket" "event_archive" {
  bucket = "eventbridge-events-archive"
  tags   = var.tags
  force_destroy = true
}

resource aws_s3_bucket_lifecycle_configuration "infrequent_access" {
  bucket = aws_s3_bucket.event_archive.id

  rule {
    id      = "event-archive-infrequent-access"
    status  = "Enabled"
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
