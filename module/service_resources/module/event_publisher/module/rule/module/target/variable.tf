variable "event_bus_name" {
  description = "The name of the event bus for which resources are to be created"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
}

variable "event_name" {
    description = "The name of the event (=detail-type) to be subscribed to"
    type        = string
}

variable "subscriber_dst_arn" {
    description = "The ARN of the API destination to be invoked"
    type        = string
}

variable "event_subscriber_connection_role_arn" {
    description = "The ARN of the IAM role that grants the event bus permission to invoke the API destination"
    type        = string
}

variable "event_rule_name" {
    description = "The name of the event rule to be pegged to this target"
    type        = string
}
