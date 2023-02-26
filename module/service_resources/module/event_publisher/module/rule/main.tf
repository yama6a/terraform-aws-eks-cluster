data "aws_caller_identity" "current_aws_account" {}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name           = "${var.event_name}-rule"
  event_bus_name = var.event_bus_name
  is_enabled     = true
  tags           = var.tags

  event_pattern = jsonencode({
    "account" : [
      data.aws_caller_identity.current_aws_account.account_id
    ],
    "detail-type": [
      var.event_name
    ]
  })
}

module "target" {
  source   = "./module/target"
  for_each = var.subscriber_dst_arns

  subscriber_dst_arn                   = each.key
  event_bus_name                       = var.event_bus_name
  event_name                           = var.event_name
  event_rule_name                      = aws_cloudwatch_event_rule.event_rule.name
  event_subscriber_connection_role_arn = var.event_subscriber_connection_role_arn
  tags                                 = var.tags
}
