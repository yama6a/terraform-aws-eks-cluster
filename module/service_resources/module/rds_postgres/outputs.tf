output "rds_postgres_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "iam_policy_arn" {
  description = "The IAM policy ARN"
  value       = aws_iam_policy.rds_iam_policy.arn
}

output "postgres_db_password_asm_secret_arn" {
  description = "The ARN for the secret holding the PostGres RDS password in AWS Secret Manager"
  value       = aws_secretsmanager_secret.password.arn
}

output "rds_postgres_host" {
    description = "The RDS PostGres host"
    value       = module.rds_postgres.db_instance_address
}
