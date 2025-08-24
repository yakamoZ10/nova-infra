module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.32"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_ip_family         = "ipv4"
  cluster_service_ipv4_cidr = "172.20.0.0/16"

  cluster_addons = {
    coredns = {
      preserve          = true
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  # Encryption
  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }

  iam_role_name = var.iam_role_name

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  create_cluster_security_group = true
  cluster_security_group_name   = var.cluster_security_group_name

  create_node_security_group = true
  node_security_group_name   = var.node_security_group_name

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    attach_cluster_primary_security_group = true
    iam_role_attach_cni_policy            = true
    # vpc_security_group_ids                = [aws_security_group.additional.id]
    force_update_version = true
  }

  eks_managed_node_groups = {
    tools = {
      name         = "tools"
      min_size     = 1
      max_size     = 3
      desired_size = 2

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp2"
            encrypted             = true
            kms_key_id            = var.kms_key_arn
            delete_on_termination = true
          }
        }
      }

      instance_types = ["t3.medium"]
      capacity_type  = var.capacity_type
      # labels         = var.tags

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      #tags = var.tags
    }
  }

  enable_irsa = true

  enable_cluster_creator_admin_permissions = true

  # aws-auth configmap
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = var.tags
}

module "ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true
  ebs_csi_kms_cmk_ids   = [var.kms_key_arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}