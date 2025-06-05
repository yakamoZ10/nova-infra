output "github_aws_iam_oidc_role_arns" {
  description = "The ARN of the IAM role that allows GitHub to assume it"
  value       = module.github_oidc_roles.github_aws_iam_oidc_role_arns
}