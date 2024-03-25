data "aws_caller_identity" "current_aws_account" {}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name           = "${var.event_name}__${var.subscriber_service_name}__${var.messageGroupId}"
  event_bus_name = var.event_bus_name
  state          = "ENABLED"
  tags           = var.tags

  event_pattern = jsonencode({
    "account" : [
      data.aws_caller_identity.current_aws_account.account_id
    ],
    "detail-type" : [
      var.event_name
    ]
  })
}

// wait 10 seconds, because apparently, after the rule is created, it can take a while until the rule is available for the target
resource "time_sleep" "wait_10_seconds" {
  depends_on = [
    aws_cloudwatch_event_rule.event_rule
  ]

  create_duration = "10s"
}

// eventbus target for api destination
resource "aws_cloudwatch_event_target" "eventbus_target" {
  depends_on = [
    time_sleep.wait_10_seconds
  ]

  event_bus_name = var.event_bus_name
  arn            = var.subscription_queue_arn
  rule           = aws_cloudwatch_event_rule.event_rule.name


  sqs_target {
    message_group_id = var.messageGroupId
  }

  retry_policy {
    maximum_event_age_in_seconds = 86400
    maximum_retry_attempts       = 185
  }
}
