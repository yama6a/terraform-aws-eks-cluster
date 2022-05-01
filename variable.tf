variable "project_name" {
  type        = string
  description = "Name of your project, used in resource names"
}

variable "env" {
  type        = string
  description = "Name of the Environment (e.g. `production` or `staging`)"
}

variable "high_availability" {
  type        = bool
  description = "Deploy high-availability cluster with at least 3 nodes and higher performance? (costs about 6x more)"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable tags {
  type        = map(string)
  default     = {}
  description = "Map of tags to be attached to all AWS resources"
}
