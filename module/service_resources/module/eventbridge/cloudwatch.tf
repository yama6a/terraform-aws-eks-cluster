data "aws_caller_identity" "current" {}

locals {
  cw_log_group_name = "/aws/events/${var.event_bus_name}-catchall"
  region = var.aws_region
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = local.cw_log_group_name
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_events_encryption_key.arn
  tags              = var.tags
}

resource "aws_kms_alias" "cloudwatch_events_encryption_key_alias" {
  name          = "alias/cloudwatch_events_encryption_key"
  target_key_id = aws_kms_key.cloudwatch_events_encryption_key.key_id
}

resource "aws_kms_key" "cloudwatch_events_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for Cloudwatch Eventbridge Event encryption"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  tags                     = var.tags
  policy                   = jsonencode({
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "logs.${var.aws_region}.amazonaws.com"
        },
        "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource": "*",
        "Condition": {
          "ArnLike": {
            "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cw_log_group_name}"
          }
        }
      }
    ]
  })
}
