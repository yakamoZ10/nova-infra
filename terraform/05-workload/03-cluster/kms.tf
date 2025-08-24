resource "aws_kms_key" "default" {
  description              = "KMS key used for encrypt/descrypt operations"
  key_usage                = "ENCRYPT_DECRYPT"
  deletion_window_in_days  = 7
  is_enabled               = true
  enable_key_rotation      = false
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false
  policy                   = data.aws_iam_policy_document.kms_key_policy.json

  tags = module.default_tags.default_tags

  lifecycle {
    prevent_destroy = false
  }
}

# resource "aws_kms_alias" "default" {
#   name          = "alias/eks-cluster-key"
#   target_key_id = join("", aws_kms_key.default.*.id)
# }