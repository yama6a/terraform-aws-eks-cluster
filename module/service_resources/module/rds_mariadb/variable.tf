variable "instance_name" {
  description = "Name of the DB Instance"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Cluster Security Group ID"
  type        = string
}

variable "multi_az" {
  description = "Should this db have a failover-ready replica in a different data center? (doubles the cost of the instance!)"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for the RDS instance"
  type        = bool
  default     = true
}

variable "instance_class" {
  description = "Instance class for the DB instance: db.t4g.micro ($12/mth) db.t4g.small($25) or db.t4g.medium($50) or db.m6g.large($127)"
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition = contains([
      "db.t4g.micro",
      "db.t4g.small",
      "db.t4g.medium",
      "db.m6g.large"
    ], var.instance_class)

    error_message = "Allowed values for instance_class are `db.t4g.micro`, `db.t4g.small`, `db.t4g.medium`, `db.m6g.large`."
  }
}

variable "service_name" {
  description = "Name of the service that will use this db."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Subnet Group Name for DB Subnet from VPC"
  type        = string
}
