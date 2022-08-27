variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "VPC Subnet IDs for cluster nodes"
  type        = set(string)
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

variable "domains" {
  description = "Domains to be hosted on the cluster which will receive auto-support for external DNS and ACM certificates in services' ingresses."
  type        = set(string)
  default     = []
}
