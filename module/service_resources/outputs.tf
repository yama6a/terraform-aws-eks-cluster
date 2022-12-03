output "ecr_repository_url" {
  description = "Created ECR Repository URL"
  value       = module.ecr[0].repository_url
}

