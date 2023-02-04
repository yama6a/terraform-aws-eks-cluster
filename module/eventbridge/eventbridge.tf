module "eventbridge" {
  source = "registry.terraform.io/terraform-aws-modules/eventbridge/aws"

  //  bus_name = "${var.event_bus_name}" // todo uncomment
  bus_name = "my_bus_name"
  //  tags     = var.tags // todo tags

  rules = {
    //    "${var.event_bus_name}-catchall" = { // todo uncomment
    "my_bus_name-catchall" = {
      //      description = "Capture all ${var.event_bus_name} data" // todo uncomment
      description = "Capture all my_bus_name data in cloudwatch"
      enabled     = true

      event_pattern = jsonencode({
        "account" : [
          data.aws_caller_identity.current.account_id
        ]
      })
    }
  }

  targets = {
    //    "${var.event_bus_name}-catchall" = [ // todo uncomment
    "my_bus_name-catchall" = [
      {
        name = "cloudwatch-catchall"
        arn  = aws_cloudwatch_log_group.cloudwatch_log_group.arn
      },
      {
        name            = "firehose-to-s3-catchall"
        arn             = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
        attach_role_arn = aws_iam_role.event_bridge_firehose_s3_catchall_invocation_role.arn
      }
    ]
  }
}

resource "aws_iam_role" "event_bridge_firehose_s3_catchall_invocation_role" {
  name = "event_bridge_firehose_s3_catchall_invocation_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })

  inline_policy {
    name   = "firehose_s3_stream_policy"
    policy = data.aws_iam_policy_document.event_bridge_firehose_policy.json
  }
}

data "aws_iam_policy_document" "event_bridge_firehose_policy" {
  statement {
    actions   = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
    ]
  }
}
