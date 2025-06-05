module "tags" {
  source = "../modules/default-tags"
  additional_tags = {
    Environment = "management"
  }
}

module "s3_backend" {
  source = "../modules/s3-backend"
}

# Moulde for the OIDC
module "github_oidc_roles" {
  source              = "../modules/aws-iam-oidc"
  create              = true
  environment         = "management"
  project             = local.project
  github_org_url      = local.github_org_url
  github_repositories = local.github_repositories
  default_tags        = local.default_tags
}