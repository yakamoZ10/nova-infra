data "aws_iam_policy_document" "tf_lock_table_resource_policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        for account_id in var.aws_account_ids :
        "arn:aws:iam::${account_id}:role/github-actions-devops-engineer-associate-1-nova-infra"
      ]
    }
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      var.dynamodb_table_arn
    ]
  }
}

data "aws_iam_policy_document" "tf_state_bucket_policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        for account_id in var.aws_account_ids :
        "arn:aws:iam::${account_id}:role/github-actions-devops-engineer-associate-1-nova-infra"
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }
}
