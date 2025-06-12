

locals {
  rds_name    = "nova-postgres-${var.environment}"
  db_username = "nova_admin"
}

module "tags" {
  source = "../../modules/default-tags"
  additional_tags = {
    Environment = var.environment
  }
}

module "rds" {
  source                  = "../../modules/aws-rds"
  vpc_id                  = data.terraform_remote_state.network.outputs.shared_vpc_id
  private_subnet_ids      = data.terraform_remote_state.network.outputs.db_subnets
  rds_name                = local.rds_name
  db_username             = local.db_username
  allowed_security_groups = [] # or your private CIDRs
  tags                    = module.tags.default_tags
}

# module "rds_bootstrap" {

#   for_each = toset(["user", "course", "enrollment"])

#   source         = "../../modules/aws-rds-bootstrap"
#   microservice   = each.key

#   db_username    = var.db_username
#   db_password    = var.db_password

#   # From module.rds outputs
#   rds_host         = module.rds.rds_host
#   rds_instance_arn = module.rds.rds_instance_arn
#   rds_instance_id  = module.rds.rds_instance_id
#   rds_sg_id        = module.rds.rds_sg_id
#   rds_secret_arn   = module.rds.rds_secret_arn

#   # Networking details (VPC subnets)
#   vpc_subnet_ids = data.terraform_remote_state.network.outputs.private_subnets

#   # Lambda source Zips
#   lambda_s3_bucket   = "nova-devops-1-terraform-state"
#   lambda_create_zip  = "lambdas/create_db.zip"
#   lambda_reset_zip   = "lambdas/reset_password2.zip"
#   lambda_create_user_zip   = "lambdas/create_user.zip"
#   # Optional: trigger execution on apply
#   trigger_execution  = true

# }
