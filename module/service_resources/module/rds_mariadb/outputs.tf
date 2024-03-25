output "instance_endpoint" {
  description = "The MariaDB connection endpoint"
  value       = module.rds_mariadb.db_instance_endpoint
}

output "iam_policy_arn" {
  description = "The IAM policy ARN"
  value       = aws_iam_policy.rds_iam_policy.arn
}

output "password_asm_secret_arn" {
  description = "The ARN for the secret holding the MariaDB RDS password in AWS Secret Manager"
  value       = module.rds_mariadb.db_instance_master_user_secret_arn
}

output "host" {
  description = "The RDS MariaDB host"
  value       = module.rds_mariadb.db_instance_address
}
