resource "aws_s3_bucket_policy" "tf_state" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.tf_state_bucket_policy.json
}

resource "aws_dynamodb_resource_policy" "tf_lock_table" {
  resource_arn = var.dynamodb_table_arn
  policy       = data.aws_iam_policy_document.tf_lock_table_resource_policy.json
}