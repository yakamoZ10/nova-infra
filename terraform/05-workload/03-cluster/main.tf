locals {
  env = var.environment

  project                     = "nova"
  region                      = "eu-central-1"
  cluster_name                = "nova-eks-${local.env}"
  cluster_security_group_name = "nova-eks-cluster-sg-${local.env}"
  nodes_additional_sg_name    = "nova-eks-additional-sg-${local.env}"
  node_security_group_name    = "nova-eks-nodes-sg-${local.env}"
  iam_role_name               = "nova-eks-cluster-role-${local.env}"

  # aws_github_oidc_iam_role_arn = data.terraform_remote_state.organization.outputs.

  default_tags = module.default_tags.default_tags
}

module "default_tags" {
  source = "../../modules/default-tags"
}

module "eks" {
  source                      = "../../modules/eks"
  cluster_name                = local.cluster_name
  vpc_id                      = data.terraform_remote_state.vpc.outputs.shared_vpc_id
  subnet_ids                  = data.terraform_remote_state.vpc.outputs.private_subnets
  kms_key_arn                 = aws_kms_key.default.arn
  cluster_security_group_name = local.cluster_security_group_name
  nodes_additional_sg_name    = local.nodes_additional_sg_name
  node_security_group_name    = local.node_security_group_name
  iam_role_name               = local.iam_role_name
  capacity_type               = "SPOT"
  tags                        = module.default_tags.default_tags
}