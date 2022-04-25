variable "region" {
  default     = "eu-north-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

locals {
  project_name = "tftest"
}
