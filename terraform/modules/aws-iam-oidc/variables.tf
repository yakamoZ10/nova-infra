
# Create variable
variable "create" {
  type    = bool
  default = true
}

# Enviroment variable
variable "environment" {
  type = string
}

# Project variable
variable "project" {
  type = string
}

# Github URL variable
variable "github_org_url" {
  type = string
}

# Github repositories
variable "github_repositories" {
  type = list(object({
    name   = string
    policy = any
  }))
}

# Default tags variable
variable "default_tags" {
  type = map(string)
}