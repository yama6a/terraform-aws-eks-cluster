resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "${var.event_bus_name}_${var.event_name}_${split("/", var.subscriber_dst_arn)[1]}_dead-letter"
  message_retention_seconds = 1209600
  tags                      = var.tags
}

// eventbus target for api destination
resource "aws_cloudwatch_event_target" "eventbus_target" {
  event_bus_name = var.event_bus_name
  arn            = var.subscriber_dst_arn
  rule           = var.event_rule_name
  role_arn       = var.event_subscriber_connection_role_arn

  dead_letter_config {
    arn = aws_sqs_queue.dead_letter_queue.arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 86400
    maximum_retry_attempts       = 185
  }
}
