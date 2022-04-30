output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_private_subnet_ids" {
  description = "Set of IDs of created private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnet_ids" {
  description = "Set of IDs of created public subnets"
  value       = module.vpc.public_subnets
}
