output "s3_firehose_stream_arn" {
  value       = aws_kinesis_firehose_delivery_stream.firehose_s3_event_archive.arn
  description = "The ARN of the Kinesis Firehose stream that pipes all events into the s3 event bucket for archival purposes."
}

output "eventbridge_to_firehose_iam_role_arn" {
  value       = aws_iam_role.eventbridge_to_firehose_iam_role.arn
  description = "The ARN of the IAM role that is used by Eventbridge to invoke the Kinesis Firehose stream that pipes all events into the s3 event bucket for archival purposes."
}

output "event_subscriber_connection_arn" {
  value       = aws_cloudwatch_event_connection.event_subscriber_connection.arn
  description = "The ARN of the Eventbridge connection that is used to push events to services."
}

output "event_subscriber_connection_role_arn" {
  value       = aws_iam_role.event_subscriber_connection_role.arn
  description = "The ARN of the IAM role that is used by Eventbridge to invoke the API Destinations through the pre-created connection."
}

output "event_subscriber_connection_secret_arn" {
  value       = aws_cloudwatch_event_connection.event_subscriber_connection.secret_arn
  description = "The ARN of the API Key used to publish events to services."
}
