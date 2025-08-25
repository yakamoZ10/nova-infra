



module "tags" {
  source = "../modules/default-tags"
  additional_tags = {
    Environment = "management"
  }
}

module "aws_org" {
  source       = "../modules/aws-org"
  org_ous      = local.org_ous
  aws_accounts = local.aws_accounts
}


module "aws_cf_stacksets" {
  source          = "../modules/aws-cf-stacksets"
  target_ou_names = local.target_ou_names
  default_tags    = module.tags.default_tags

  depends_on = [module.aws_org]
}

resource "aws_ram_sharing_with_organization" "this" {}

module "s3_backend_policies" {
  source             = "../modules/s3-backend/resource-policies"
  s3_bucket_id       = data.terraform_remote_state.bootstrap.outputs.aws_s3_bucket_id
  s3_bucket_arn      = data.terraform_remote_state.bootstrap.outputs.aws_s3_bucket_arn
  dynamodb_table_arn = data.terraform_remote_state.bootstrap.outputs.aws_dynamodb_table_arn
  aws_account_ids    = local.aws_account_ids
  depends_on = [
    module.aws_org
  ]
}