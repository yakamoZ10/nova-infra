module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "temp-eks-cluster"
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }
  }

  aws_auth_roles = [
    {
      rolearn  = var.admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  tags = var.default_tags
}
