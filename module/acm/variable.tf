variable "domain" {
  description = "Domain to receive an ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject Alternative Names to be attached to the certificate"
  type        = set(string)
  default     = []
}


variable "tags" {
  description = "Tags to be attached to all resources"
  type        = map(string)
  default     = {}
}
