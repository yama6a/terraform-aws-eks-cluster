variable "event_bus_name" {
  type        = string
  description = "The name of the event bus to create."
}

variable "service_name" {
  type        = string
  description = "The name of the service to create."
}

variable "cloudwatch_retention_days" {
  type        = number
  default     = 30
  description = "The number of days to retain events in CloudWatch for this event bus."
}

variable "s3_history_storage" {
  type        = string
  default     = "true"
  description = "Whether to enable history storage in Amazon S3 for this event bus."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to be attached to all AWS resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resources"
}
