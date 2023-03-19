variable "tags" {
  type        = map(string)
  description = "Map of tags to be attached to all AWS resources"
}

variable "subscriber_service_name" {
  description = "The name of the service that subscribes to an event"
  type        = string
}

variable "subscriptions" {
  description = "A list of subscriptions to create"
  type        = list(object({
    event_bus_name = string
    event_name     = string
    messageGroupId    = string
  }))
}
