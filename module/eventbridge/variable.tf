variable "tags" {
  description = "Tags to be attached to all cluster resources"
  type        = map(string)
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
