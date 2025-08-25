import {
  to = module.s3_backend.aws_s3_bucket.tf_state
  id = "nova-devops-1-terraform-state"
}

import {
  to = module.s3_backend.aws_dynamodb_table.tf_lock_table
  id = "nova-devops-1-terraform-state-lock"
}