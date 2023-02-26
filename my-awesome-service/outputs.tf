output "ecr_repository_url" {
  description = "Created ECR Repository URL"
  value       = module.ecr.repository_url
}

output "asm_postgres_db_password_arns" {
  description = "Created ASM Postgres DB Password ARNs"
  value       = module.main_postgres.password_asm_secret_arn
}

output "rds_postgres_hosts" {
  description = "Created RDS Postgres Hosts"
  value       = module.main_postgres.host
}

output "asm_mysql_db_password_arns" {
  description = "Created ASM MySQL DB Password ARNs"
  value       = module.main_mysql.password_asm_secret_arn
}

output "rds_mysql_hosts" {
  description = "Created RDS MySQL Hosts"
  value       = module.main_mysql.host
}

output "asm_mariadb_db_password_arns" {
  description = "Created ASM MariaDB DB Password ARNs"
  value       = module.main_mariadb.password_asm_secret_arn
}

output "rds_mariadb_hosts" {
  description = "Created RDS MariaDB Hosts"
  value       = module.main_mariadb.host
}

output "eventbridge_bus_arn" {
  description = "Created EventBridge Bus ARN"
  value       = module.event_publisher.event_bus_arn
}

output "eventbridge_subscription_destination_arn" {
  description = "Created EventBridge Subscription Destination ARN"
  value       = (length(aws_cloudwatch_event_api_destination.event_subscription_api_destination) > 0) ? aws_cloudwatch_event_api_destination.event_subscription_api_destination[0].arn : null
}
