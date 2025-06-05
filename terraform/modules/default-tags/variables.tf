variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to be added to all AWS resources"
  default     = {}
}