locals {
  github_certificate = [data.tls_certificate.certificate.certificates[0].sha1_fingerprint]

  repos = [
    {
      name = "devops-engineer-associate-1/nova-infra"
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = [
              "vpc:*",
              "ec2:*",
              "cloudformation:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
    },
    {
      name = "devops-engineer-associate-1/nova-web"
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = [
              "vpc:*",
              "ec2:*",
              "cloudformation:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
    },
    {
      name = "devops-engineer-associate-1/nova-api"
      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = [
              "vpc:*",
              "ec2:*",
              "cloudformation:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
    }
  ]

  target_ou_names = ["Infrastructure", "Workloads"]
  target_ou_ids   = [for ou in data.aws_organizations_organizational_units.root_ous.children : ou.id if contains(local.target_ou_names, ou.name)]
}

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

# --------------------------------------------------------------
# AWS Resources for CloudFormation 
# --------------------------------------------------------------

resource "aws_cloudformation_stack_set" "github_oidc_provider" {
  name             = "github-action-oidc-provider"
  permission_model = "SERVICE_MANAGED"
  template_body    = file("${path.module}/templates/github_action_oidc_provider.yaml")

  parameters = {
    GitHubCertificate = join(",", local.github_certificate)
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    failure_tolerance_count = 1
    max_concurrent_count    = 3
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}

resource "aws_cloudformation_stack_set_instance" "github_oidc_provider_deployments" {
  stack_set_name = aws_cloudformation_stack_set.github_oidc_provider.name

  deployment_targets {
    organizational_unit_ids = local.target_ou_ids
  }

  depends_on = [aws_cloudformation_stack_set.github_oidc_provider]
}

resource "aws_cloudformation_stack_set" "github_iam_role" {
  for_each = { for repo in local.repos : repo.name => repo }

  name             = "github-oidc-${replace(each.key, "/", "-")}"
  permission_model = "SERVICE_MANAGED"
  template_body    = file("${path.module}/templates/github_action_iam_role.yaml")

  parameters = {
    GitHubRepo        = each.key
    SanitizedRepoName = replace(each.key, "/", "-")
    CustomPolicy      = each.value.policy
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    failure_tolerance_count = 1
    max_concurrent_count    = 3
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}

resource "aws_cloudformation_stack_set_instance" "github_iam_role_deployments" {
  for_each = { for repo in local.repos : repo.name => repo }

  stack_set_name = aws_cloudformation_stack_set.github_iam_role[each.key].name

  deployment_targets {
    organizational_unit_ids = local.target_ou_ids
  }

  depends_on = [aws_cloudformation_stack_set.github_iam_role]
}
