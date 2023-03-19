variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
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

variable "messageGroupId" {
  description = "The suffix to be used for the event rule name. Can be omitted if the service subscribes to the event only once. All subsequent subscriptions need a suffix to be unique."
  type        = string
  validation {
    condition     = length(var.messageGroupId) > 1
    error_message = "Must be a at least 2 characters long."
  }
}

variable "subscription_queue_arn" {
  description = "The ARN of the queue to which the event is to be sent"
  type        = string
}
