variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "oidc_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_arn" {
    description = "ARN of the OIDC provider"
    type        = string
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}
