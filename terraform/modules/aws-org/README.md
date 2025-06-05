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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.this](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.child_ous](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.parent_ous](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | n/a | <pre>list(object({<br>    name              = string<br>    email             = string<br>    parent_id         = string<br>    close_on_deletion = optional(bool, false)<br>    tags              = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_org_ous"></a> [org\_ous](#input\_org\_ous) | n/a | <pre>list(object({<br>    name      = string<br>    parent_id = string<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->