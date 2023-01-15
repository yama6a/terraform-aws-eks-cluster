variable "service_name" {
  description = "The name of the service for which resources are to be created"
  type        = string
}

variable "create_ecr_repo" {
  type        = bool
  description = "Create ECR repo for this service"
}

variable "enable_dynamodb_access" {
  type        = bool
  description = "Create DynamoDB ARN Policy for this service to be able to create and manage tables"
}

variable "postgres_databases" {
  type = list(object({
    # Name of the database instance (suffixed to the service-name)
    db_name = string
    # Instance class of the database (e.g. db.t4g.micro)
    instance_class = string
    # Whether to deploy the database in multiple availability zones
    multi_az = bool
    # Enable Deletion Protection (should always be true! To delete a DB, set to false, then apply, then remove object, then apply again)
    deletion_protection = bool
  }))
  default     = []
  description = "List of postgres databases."
}

variable "mysql_databases" {
  type = list(object({
    # Name of the database instance (suffixed to the service-name)
    db_name = string
    # Instance class of the database (e.g. db.t4g.micro)
    instance_class = string
    # Whether to deploy the database in multiple availability zones
    multi_az = bool
    # Enable Deletion Protection (should always be true! To delete a DB, set to false, then apply, then remove object, then apply again)
    deletion_protection = bool
  }))
  default     = []
  description = "List of mysql databases."
}

variable "mariadb_databases" {
  type = list(object({
    # Name of the database instance (suffixed to the service-name)
    db_name = string
    # Instance class of the database (e.g. db.t4g.micro)
    instance_class = string
    # Whether to deploy the database in multiple availability zones
    multi_az = bool
    # Enable Deletion Protection (should always be true! To delete a DB, set to false, then apply, then remove object, then apply again)
    deletion_protection = bool
  }))
  default     = []
  description = "List of mariadb databases."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to be attached to all AWS resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_subnet_group_name" {
  type        = string
  description = "VPC Subnet Group Name to place created DBs in"
}

variable "db_security_group_id" {
  type        = string
  description = "EKS Cluster Security Group ID to give access to the database"
}

variable "oidc_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}
