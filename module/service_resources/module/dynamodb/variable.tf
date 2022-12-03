variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}
