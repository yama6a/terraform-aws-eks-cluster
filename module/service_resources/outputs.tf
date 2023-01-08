output "ecr_repository_url" {
  description = "Created ECR Repository URL"
  value       = module.ecr[0].repository_url
}

output "asm_postgres_db_password_arns" {
    description = "Created ASM Postgres DB Password ARN"
    value       = module.postgres[*].postgres_db_password_asm_secret_arn
}

output "rds_postgres_hosts" {
    description = "Created RDS Postgres Hosts"
    value       = module.postgres[*].rds_postgres_host
}
