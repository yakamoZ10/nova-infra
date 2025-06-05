variable "org_ous" {
  type = list(object({
    name      = string
    parent_id = string
  }))
}

variable "aws_accounts" {
  type = list(object({
    name              = string
    email             = string
    parent_id         = string
    close_on_deletion = optional(bool, false)
    tags              = optional(map(string), {})
  }))
}