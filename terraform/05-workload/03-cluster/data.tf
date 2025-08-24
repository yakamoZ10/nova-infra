data "aws_caller_identity" "default" {}

# data "terraform_remote_state" "organization" {
#   backend = "s3"

#   config = {
#     bucket         = "astra-devops-1-terraform-state"
#     key            = "management/01-organization/terraform.tfstate"
#     skip_region_validation = true
#     region         = "eu-central-1"
#   }
# }

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket                 = "nova-devops-1-terraform-state"
    key                    = "network/03-shared-networking/terraform.tfstate"
    skip_region_validation = true
    region                 = "eu-central-1"
  }
}

data "aws_iam_policy_document" "kms_key_policy" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/github-actions-devops-engineer-associate-1-astra-infra"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/github-actions-devops-engineer-associate-1-astra-infra",
        module.eks.cluster_iam_role_arn,
        module.eks.ebs_csi_irsa_iam_role_arn
      ]
    }
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKeyWithoutPlainText",
      "kms:ReEncrypt"
    ]
    resources = ["*"]
  }
}