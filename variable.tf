variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable tags {
  type        = map(string)
  default     = {}
  description = "Map of tags to be attached to all AWS resources"
}
