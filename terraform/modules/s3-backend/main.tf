# Create S3 bucket for storing Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = "nova-devops-1-terraform-state"
}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.tf_state]
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking and consistency checks
resource "aws_dynamodb_table" "tf_lock_table" {
  name         = "nova-devops-1-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
