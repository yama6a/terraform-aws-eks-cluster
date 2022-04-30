variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to all resources"
  type        = map(string)
  default     = {}
}
