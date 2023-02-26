variable "event_bus_name" {
  description = "The name of the event bus for which resources are to be created"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "firehose_s3_event_archive_stream_arn" {
  description = "The ARN of the Kinesis Firehose stream which pipes into s3 to which all events are archived"
  type        = string
}

variable "event_bridge_firehose_s3_catchall_invocation_role_arn" {
  description = "The ARN of the IAM role which is used to invoke the Kinesis Firehose stream which pipes into s3 to which all events are archived"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
}

variable "event_subscribers" {
  description = "Map of event name to subscriber target ARNs"
  type        = map(list(string))
}
