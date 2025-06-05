# OIDC ARN output
output "github_aws_iam_oidc_role_arns" {
  description = "The ARN of the IAM role that allows GitHub to assume it"
  value       = [for role in aws_iam_role.this : role.arn]

}