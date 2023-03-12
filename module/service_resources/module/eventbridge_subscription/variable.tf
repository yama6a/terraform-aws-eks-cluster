variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "event_bus_name" {
  description = "The name of the event bus for which resources are to be created"
  type        = string
}

variable "event_name" {
  description = "The name of the event (=detail-type) to be subscribed to"
  type        = string
}

variable "subscriber_service_name" {
  description = "The name of the service that subscribes to an event"
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

variable "api_destination_arn" {
  description = "The ARN of the API destination to be used for event subscriptions"
  type        = string
}

variable "rule_suffix" {
  description = "The suffix to be used for the event rule name. Can be omitted if the service subscribes to the event only once. All subsequent subscriptions need a suffix to be unique"
  type        = string
  default     = ""
}
