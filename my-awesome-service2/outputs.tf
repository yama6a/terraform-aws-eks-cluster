output "ecr_repository_url" {
  description = "Created ECR Repository URL"
  value       = module.ecr.repository_url
}

output "asm_postgres_db_password_arns" {
  description = "Created ASM Postgres DB Password ARNs"
  value       = module.main_postgres.password_asm_secret_arn
}

output "rds_postgres_host" {
  description = "Created RDS Postgres Hosts"
  value       = module.main_postgres.host
}

output "asm_mysql_db_password_arns" {
  description = "Created ASM MySQL DB Password ARNs"
  value       = module.main_mysql.password_asm_secret_arn
}

output "rds_mysql_host" {
  description = "Created RDS MySQL Hosts"
  value       = module.main_mysql.host
}

output "asm_mariadb_db_password_arns" {
  description = "Created ASM MariaDB DB Password ARNs"
  value       = module.main_mariadb.password_asm_secret_arn
}

output "rds_mariadb_host" {
  description = "Created RDS MariaDB Hosts"
  value       = module.main_mariadb.host
}

output "eventbridge_bus_arn" {
  description = "Created EventBridge Bus ARN"
  value       = module.event_publisher.event_bus_arn
}

output "event_subscription_queue_url" {
  description = "Created Event Queue URL"
  value       = module.event_subscriber.sqs_subscription_queue_url
}

output "event_subscription_dlq_url" {
  description = "Created Event DLQ URL"
  value       = module.event_subscriber.sqs_dead_letter_queue_url
}
