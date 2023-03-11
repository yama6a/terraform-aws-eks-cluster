resource "aws_iam_role" "eventbridge_to_firehose_iam_role" {
  name = "eventbridge_to_firehose_iam_role"
  tags = var.tags

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  inline_policy {
    name   = "firehose_s3_stream_policy"
    policy = data.aws_iam_policy_document.eventbridge_to_firehose_iam_policy.json
  }
}

data "aws_iam_policy_document" "eventbridge_to_firehose_iam_policy" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.firehose_s3_event_archive.arn
    ]
  }
}
