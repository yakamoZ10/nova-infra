locals {
  vpc_cidr_block = "10.0.0.0/16"
  environment    = "shared"

  default_tags = merge({ Environment = local.environment }, module.tags.default_tags)
}

module "tags" {
  source = "../modules/default-tags"
  additional_tags = {
    Environment = "local.environment"
  }
}

module "vpc" {
  source         = "../modules/aws-vpc"
  name           = "nova-shared-vpc"
  environment    = local.environment
  vpc_cidr_block = local.vpc_cidr_block
  default_tags   = local.default_tags
}
