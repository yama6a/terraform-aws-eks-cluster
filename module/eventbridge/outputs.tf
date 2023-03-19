output "s3_firehose_stream_arn" {
  value       = aws_kinesis_firehose_delivery_stream.firehose_s3_event_archive.arn
  description = "The ARN of the Kinesis Firehose stream that pipes all events into the s3 event bucket for archival purposes."
}

output "eventbridge_to_firehose_iam_role_arn" {
  value       = aws_iam_role.eventbridge_to_firehose_iam_role.arn
  description = "The ARN of the IAM role that is used by Eventbridge to invoke the Kinesis Firehose stream that pipes all events into the s3 event bucket for archival purposes."
}
