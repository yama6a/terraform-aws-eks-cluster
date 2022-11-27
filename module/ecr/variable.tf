variable "repository_name" {
  description = "Name of the ECR Repository"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}

variable "service_name" {
  description = "Name of the Service that needs an ECR Repository"
  type        = string
}
