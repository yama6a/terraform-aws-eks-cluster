data "aws_caller_identity" "current_aws_account" {}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name           = "${var.event_bus_name}.${var.event_name}__${var.subscriber_service_name}_sub"
  event_bus_name = var.event_bus_name
  is_enabled     = true
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

// eventbus target for api destination
resource "aws_cloudwatch_event_target" "eventbus_target" {
  event_bus_name = var.event_bus_name
  arn            = var.api_destination_arn
  rule           = aws_cloudwatch_event_rule.event_rule.name
  role_arn       = var.event_subscriber_connection_role_arn

  dead_letter_config {
    arn = aws_sqs_queue.dead_letter_queue.arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 86400
    maximum_retry_attempts       = 185
  }
}

// DLQ for undelivered messages
resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "${var.event_bus_name}_${var.event_name}__${var.subscriber_service_name}_dead-letter"
  message_retention_seconds = 1209600
  tags                      = var.tags
}
