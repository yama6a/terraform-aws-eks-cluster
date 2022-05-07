output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster Name."
  value       = module.eks.cluster_name
}

output "cluster_node_group_name" {
  description = "EKS cluster NodeGroup Names."
  value       = module.eks.node_group_name
}

output "vpc_id" {
  description = "AWS region"
  value       = module.vpc.vpc_id
}
