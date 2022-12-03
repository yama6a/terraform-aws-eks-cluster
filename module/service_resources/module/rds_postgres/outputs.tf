output "rds_postgres_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "iam_policy_arn" {
  description = "The IAM policy ARN"
  value       = aws_iam_policy.rds_iam_policy.arn
}
