variable "cluster_id" {
    description = "ID of the EKS cluster"
    type        = string
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}

variable "oidc_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "policy_arns" {
  description = "ARNs of the policies to attach to the role"
  type        = list(string)
}
