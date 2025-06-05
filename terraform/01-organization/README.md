<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.97.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_org"></a> [aws\_org](#module\_aws\_org) | ../modules/aws-org | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | ../modules/default-tags | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.github_iam_role](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set.github_oidc_provider](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.github_iam_role_deployments](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_cloudformation_stack_set_instance.github_oidc_provider_deployments](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_units.root_ous](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/organizations_organizational_units) | data source |
| [tls_certificate.certificate](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->