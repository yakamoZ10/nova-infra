output "github_aws_iam_oidc_role_arns" {
  description = "The ARN of the IAM role that allows GitHub to assume it"
  value       = module.github_oidc_roles.github_aws_iam_oidc_role_arns
}

output "aws_s3_bucket_arn" {
  value       = module.s3_backend.aws_s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "aws_s3_bucket_id" {
  value       = module.s3_backend.aws_s3_bucket_id
  description = "The ID of the S3 bucket"
}

output "aws_dynamodb_table_arn" {
  value       = module.s3_backend.aws_dynamodb_table_arn
  description = "The ARN of the DynamoDB table"
}