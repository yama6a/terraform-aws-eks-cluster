variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "vpc" {
  description = "VPC Parameters"
  type        = object({
    id         = string
    subnet_ids = set(string)
  })
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}

variable "high_availability" {
  description = "Is this cluster intended for production use ?"
  type        = bool
  default     = false
}
