locals {
  default_tags = {
    Owner      = "yakamoZ"
    Project    = "nova"
    Group      = "DevOps Engineer Associate - Group 1"
    Repository = "https://github.com/yakamoZ10/nova-infra"
    ManagedBy  = "Terraform"
  }

  merged_tags = merge(local.default_tags, var.additional_tags)
}
