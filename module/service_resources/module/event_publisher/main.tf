data "aws_caller_identity" "current_aws_account" {}

// Event Bus that the current service will publish events on
module "eventbridge" {
  source  = "registry.terraform.io/terraform-aws-modules/eventbridge/aws"
  version = "~> 3.0"

  bus_name = var.event_bus_name
  tags     = var.tags

  rules = {
    "catchall" = {
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
    "catchall" = [
      {
        name = "cloudwatch-catchall"
        arn  = aws_cloudwatch_log_group.cloudwatch_log_group.arn
      },
      {
        name            = "firehose-to-s3-catchall"
        arn             = var.firehose_s3_event_archive_stream_arn
        attach_role_arn = var.event_bridge_firehose_s3_catchall_invocation_role_arn
      }
    ]
  }
}
