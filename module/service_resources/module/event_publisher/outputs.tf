output "iam_eventbridge_publishing_policy_arn" {
  description = "The ARN of the policy created for Eventbridge publishing access"
  value       = aws_iam_policy.eventbridge_policy.arn
}

output "event_bus_arn" {
  description = "The ARN of the Eventbridge bus"
  value       = module.eventbridge.eventbridge_bus_arn
}
