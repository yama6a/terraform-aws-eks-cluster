output "sqs_subscription_queue_url" {
  value       = aws_sqs_queue.subscription_queue.url
  description = "The URL of the SQS queue to consume events from"
}

output "sqs_dead_letter_queue_url" {
  value       = aws_sqs_queue.dead_letter_queue.url
  description = "The URL of the SQS queue to handle dead letter messages"
}

output "iam_sqs_consumer_policy_arn" {
  value       = aws_iam_policy.consumer_policy.arn
  description = "The ARN of the IAM policy that allows a service (or SA) to consume messages from the SQS queue and DLQ"
}
