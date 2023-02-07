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

output "ecr_repo_urls" {
  value = [
    for service in module.service_resources : service.ecr_repository_url
  ]
}

output "postgres_password_secret_ARNs" {
  value = [
    for service in module.service_resources : service.asm_postgres_db_password_arns
  ]
}

output "postgres_hosts" {
  value = [
    for service in module.service_resources : service.rds_postgres_hosts
  ]
}

output "mysql_password_secret_ARNs" {
  value = [
    for service in module.service_resources : service.asm_mysql_db_password_arns
  ]
}

output "mysql_hosts" {
  value = [
    for service in module.service_resources : service.rds_mysql_hosts
  ]
}

output "mariadb_password_secret_ARNs" {
  value = [
    for service in module.service_resources : service.asm_mariadb_db_password_arns
  ]
}

output "mariadb_hosts" {
  value = [
    for service in module.service_resources : service.rds_mariadb_hosts
  ]
}

output "eventbus_ARNs" {
  value = [
    for service in module.service_resources : service.eventbridge_bus_arn
  ]
}
