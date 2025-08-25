locals {
  github_certificate = [data.tls_certificate.certificate.certificates[0].sha1_fingerprint]

  repos = [
    "yakamoZ10/nova-infra",
    "yakamoZ10/nova-web",
    "yakamoZ10/nova-api"
  ]

  target_ou_ids = [for ou in data.aws_organizations_organizational_units.root_ous.children : ou.id if contains(var.target_ou_names, ou.name)]

  default_cf_stack_sets = flatten([
    {
      name        = "github-action-oidc-provider"
      description = "OIDC Provider for GitHub Actions"
      template    = "${path.module}/templates/github_action_oidc_provider.yaml"
      parameters = {
        GitHubCertificate = join(",", local.github_certificate)
      }
      deployment_targets = local.target_ou_ids
    },
    [
      for repo in local.repos : {
        name        = "github-action-iam-role-${repo}"
        description = "IAM Role for GitHub Actions for ${repo}"
        template    = "${path.module}/templates/github_action_iam_role.yaml"
        parameters = {
          GitHubRepo       = repo
          ManagedPolicyARN = "arn:aws:iam::aws:policy/AdministratorAccess"
          S3BucketName = "astra-devops-1-terraform-state"
          DynamoDBTableARN = "arn:aws:dynamodb:eu-central-1:693868819116:table/astra-devops-1-terraform-state-lock"
        }
        deployment_targets = local.target_ou_ids
      }
    ]
  ])

  all_stack_sets = concat(local.default_cf_stack_sets, var.cf_stack_set)
}

resource "aws_cloudformation_stack_set" "this" {
  for_each = { for stack_set in local.all_stack_sets : stack_set.name => stack_set }

  name             = "${replace(each.key, "/", "-")}"
  permission_model = "SERVICE_MANAGED"
  description      = each.value.description
  template_body    = file(each.value.template)

  parameters = each.value.parameters

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    failure_tolerance_count = 1
    max_concurrent_count    = 3
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  lifecycle {
    ignore_changes = [
      administration_role_arn
    ]
  }

  tags = var.default_tags
}

resource "aws_cloudformation_stack_instances" "this" {
  for_each = { for stack_set in local.all_stack_sets : stack_set.name => stack_set }

  stack_set_name = aws_cloudformation_stack_set.this[each.key].name

  deployment_targets {
    organizational_unit_ids = each.value.deployment_targets
  }

  depends_on = [aws_cloudformation_stack_set.this]
}