variable "s3_bucket_id" {
  description = "The ID of the S3 bucket for storing Terraform state"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for storing Terraform state"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table for state locking"
  type        = string
}

variable "aws_account_ids" {
  description = "List of AWS account IDs"
  type        = list(string)
}