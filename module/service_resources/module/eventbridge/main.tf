module "eventbridge" {
  source = "registry.terraform.io/terraform-aws-modules/eventbridge/aws"

  bus_name = "${var.service_name}.${var.event_bus_name}"
  tags     = var.tags

  rules = {
    "${var.event_bus_name}" = {
      description = "Capture all ${var.event_bus_name} data"
      enabled     = true

      event_pattern = jsonencode({
        "account" : [
          data.aws_caller_identity.current.account_id
        ]
      })
    }
  }

  targets = {
    "${var.event_bus_name}" = [
      {
        name = "cloudwatch-catchall"
        arn  = aws_cloudwatch_log_group.cloudwatch_log_group.arn
      }
    ]
  }
}
