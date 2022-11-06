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
  default     = false
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

variable "domains" {
  type        = map(set(string))
  default     = {}
  description = 'Map of {domain => [set(subject_alternative_names)]} to be hosted on the cluster which automatically receive ACM certificates. E.g. {"example.com"  = ["api.example.com", "*.api.example.com", "www.example.com"]} ALL TLDs MUST HAVE AN EXISTING HOSTED ZONE IN Route53!'
}

variable "services" {
  type = set(string)
  default = []
  description = "List of service-names to deploy be hosted on the cluster."
}
