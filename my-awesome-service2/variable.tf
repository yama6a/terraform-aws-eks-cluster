variable "service_name" {
  description = "The name of the service for which resources are to be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.service_name))
    error_message = "The service name must start and end with a lowercase alphanumeric character, can contain dashes but no double dashes and be at least 2 chars long."
  }
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_subnet_group_name" {
  type        = string
  description = "VPC Subnet Group Name to place created DBs in"
}

variable "db_security_group_id" {
  type        = string
  description = "EKS Cluster Security Group ID to give access to the database"
}

variable "oidc_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "firehose_s3_event_archive_stream_arn" {
  description = "The ARN of the Kinesis Firehose stream which pipes into s3 to which all events are archived"
  type        = string
}

variable "event_bridge_firehose_s3_invocation_role_arn" {
  description = "The ARN of the IAM role which is used to invoke the Kinesis Firehose stream which pipes into s3 to which all events are archived"
  type        = string
}

variable "event_subscriber_connection_arn" {
  description = "The ARN of the connection to be used for event subscriptions"
  type        = string
}

variable "event_subscriber_connection_role_arn" {
  description = "The ARN of the role to be used for event subscriptions"
  type        = string
}
