output "ecr_repository_url" {
  description = "Created ECR Repository URL"
  value       = module.ecr[0].repository_url
}

output "asm_postgres_db_password_arns" {
  description = "Created ASM Postgres DB Password ARNs"
  value       = module.postgres[*].password_asm_secret_arn
}

output "rds_postgres_hosts" {
  description = "Created RDS Postgres Hosts"
  value       = module.postgres[*].host
}

output "asm_mysql_db_password_arns" {
  description = "Created ASM MySQL DB Password ARNs"
  value       = module.mysql[*].password_asm_secret_arn
}

output "rds_mysql_hosts" {
  description = "Created RDS MySQL Hosts"
  value       = module.mysql[*].host
}

output "asm_mariadb_db_password_arns" {
  description = "Created ASM MariaDB DB Password ARNs"
  value       = module.mariadb[*].password_asm_secret_arn
}

output "rds_mariadb_hosts" {
  description = "Created RDS MariaDB Hosts"
  value       = module.mariadb[*].host
}

output "eventbridge_bus_arn" {
  description = "Created EventBridge Bus ARN"
  value       = module.eventbridge[0].event_bus_arn
}
