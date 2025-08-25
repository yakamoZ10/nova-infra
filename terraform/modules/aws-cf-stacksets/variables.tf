variable "cf_stack_set" {
  description = "List of CloudFormation StackSets to deploy"
  type        = list(object({
    name = string
    description = string
    template = string
    parameters = map(string)
    deployment_targets = list(string)
  }))
  default     = []
}

variable "target_ou_names" {
  description = "List of target Organization Units"
  type        = list(string)
}

variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

