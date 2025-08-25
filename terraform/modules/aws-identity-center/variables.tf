variable "users" {
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
  }))
}

variable "groups" {
  type = map(object({
    description = string
    users       = list(string)
  }))
}

variable "permission_sets" {
  type = list(object({
    name             = string
    description      = string
    session_duration = string
    managed_policies = list(string)
  }))
  default = []
}

variable "assignments" {
  type = list(object({
    permission_set_name = string
    principal_name      = string
    account_names       = list(string)
  }))
  default = []
}