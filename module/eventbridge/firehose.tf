resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })

  inline_policy {
    name   = "firehose_s3_stream_policy"
    policy = data.aws_iam_policy_document.firehose_inline_policy.json
  }
}


resource "aws_kms_alias" "firehose_event_encryption_key" {
  name          = "alias/firehose_event_encryption_key"
  target_key_id = aws_kms_key.firehose_event_encryption_key.key_id
}

resource "aws_kms_key" "firehose_event_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for Firehose Event encryption"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  //  tags                     = var.tags // Todo
  policy                   = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key",
        Effect = "Allow"
        "Principal": {
          "AWS": aws_iam_role.firehose_role.arn
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  kms_key_arn =

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.event_archive.arn

    buffer_size = 64
    buffer_interval = 60
    prefix              = "events/detail_type=!{partitionKeyFromQuery:detail_type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

    dynamic_partitioning_configuration {
      enabled = true
    }

    # Multi-record deaggregation processor
    processing_configuration {
      enabled = "true"

      processors {
        type = "RecordDeAggregation"
        parameters {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      }

      # Adds a new line after each record (with Firehose there will always be multiple events per file)
      processors {
        type = "AppendDelimiterToRecord"
      }

      # JQ processor to extract the detail-type (= event name) from the event's metadata
      processors {
        type = "MetadataExtraction"
        parameters { // the parameters need to be in this order, or terraform will keep trying to swap them.
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{detail_type:.\"detail-type\"}"
        }
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      }
    }
  }
}
