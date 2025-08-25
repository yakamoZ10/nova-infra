output "aws_s3_bucket_arn" {
  value = aws_s3_bucket.tf_state.arn
  description = "The ARN of the S3 bucket"
}

output "aws_dynamodb_table_arn" {
  value = aws_dynamodb_table.tf_lock_table.arn
  description = "The ARN of the DynamoDB table"
}

output "aws_s3_bucket_id" {
  value       = aws_s3_bucket.tf_state.id
  description = "The ID of the S3 bucket"
}