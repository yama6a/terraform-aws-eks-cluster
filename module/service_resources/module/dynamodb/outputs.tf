output "policy_arn" {
  description = "The ARN of the policy created for DynamoDB access"
  value       = aws_iam_policy.dynamodb_policy.arn
}
