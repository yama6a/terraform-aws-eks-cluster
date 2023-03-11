resource "aws_iam_role" "firehose_to_s3_iam_role" {
  name = "firehose_to_s3_iam_role"
  tags = var.tags

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  inline_policy {
    name   = "firehose_to_s3_iam_policy"
    policy = data.aws_iam_policy_document.firehose_to_s3_iam_policy.json
  }
}

data "aws_iam_policy_document" "firehose_to_s3_iam_policy" {
  statement {
    sid = ""
    actions = [
      "glue:GetTable",
      "glue:GetTableVersions",
      "glue:GetTableVersions"
    ]
    resources = [
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]
  }

  statement {
    sid = ""
    actions = [
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka-cluster:Connect"
    ]
    resources = [
    "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
  }

  statement {
    sid = ""
    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:DescribeTopicDynamicConfiguration",
      "kafka-cluster:ReadData"
    ]
    resources = [
    "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
  }

  statement {
    sid = ""
    actions = [
      "kafka-cluster:DescribeGroup"
    ]
    resources = [
    "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:group/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*"]
  }


  statement {
    sid = ""
    actions = [
      "glue:GetSchemaByDefinition"
    ]
    resources = [
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:registry/*",
      "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:schema/*"
    ]
  }


  statement {
    sid = ""
    actions = [
      "glue:GetSchemaVersion"
    ]
    resources = [
      "*"
    ]
  }


  statement {
    sid = ""
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.event_archive.arn,
      "${aws_s3_bucket.event_archive.arn}/*"
    ]
  }


  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [
    "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
  }


  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.${var.aws_region}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*",
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
      ]
    }
  }


  statement {
    sid = ""
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/PUT-S3-foo:log-stream:*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%:log-stream:*"
    ]
  }


  statement {
    sid = ""
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [
    "arn:aws:kinesis:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"]
  }


  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "kinesis.${var.aws_region}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [
        "arn:aws:kinesis:${var.aws_region}:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
      ]
    }
  }
}
