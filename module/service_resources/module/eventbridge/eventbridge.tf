data "aws_caller_identity" "current_aws_account" {}

module "eventbridge" {
  source = "registry.terraform.io/terraform-aws-modules/eventbridge/aws"

  bus_name = var.event_bus_name
  tags     = var.tags

  rules = {
    "${var.event_bus_name}-catchall" = {
      description = "Capture all ${var.event_bus_name} data"
      enabled     = true

      event_pattern = jsonencode({
        "account" : [
          data.aws_caller_identity.current_aws_account.account_id
        ]
      })
    }
  }

  targets = {
    "${var.event_bus_name}-catchall" = [
      {
        name = "cloudwatch-catchall"
        arn  = aws_cloudwatch_log_group.cloudwatch_log_group.arn
      },
      {
        name            = "firehose-to-s3-catchall"
        arn             = var.firehose_s3_archive_stream_arn
        attach_role_arn = var.event_bridge_firehose_s3_catchall_invocation_role_arn
      }
    ]
  }
}

resource "aws_iam_policy" "eventbridge_policy" {
  name = "${var.event_bus_name}-eventbus-policy"
  tags = var.tags

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "events:DescribeEventBus",
          "events:PutEvents",
          "events:DescribeEndpoint"
        ],
        "Resource" : [
          "arn:aws:events:eu-west-1:902409284726:event-bus/my-awesome-service",
          "arn:aws:events:*:902409284726:endpoint/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "events:ListEndpoints",
          "events:ListEventBuses"
        ],
        "Resource" : "*"
      }
    ]
  })
}
