## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Create variable | `bool` | `true` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags variable | `map(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Enviroment variable | `string` | n/a | yes |
| <a name="input_github_org_url"></a> [github\_org\_url](#input\_github\_org\_url) | Github URL variable | `string` | n/a | yes |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | Github repositories | <pre>list(object({<br/>    name   = string<br/>    policy = any<br/>  }))</pre> | n/a | yes |
| <a name="input_github_thumbprint"></a> [github\_thumbprint](#input\_github\_thumbprint) | Github thumbprint variable | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project variable | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_aws_iam_oidc_role_arn"></a> [github\_aws\_iam\_oidc\_role\_arn](#output\_github\_aws\_iam\_oidc\_role\_arn) | The ARN of the IAM role that allows GitHub to assume it |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.tfc_certificate](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Create variable | `bool` | `true` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags variable | `map(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Enviroment variable | `string` | n/a | yes |
| <a name="input_github_org_url"></a> [github\_org\_url](#input\_github\_org\_url) | Github URL variable | `string` | n/a | yes |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | Github repositories | <pre>list(object({<br>    name   = string<br>    policy = any<br>  }))</pre> | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project variable | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_aws_iam_oidc_role_arns"></a> [github\_aws\_iam\_oidc\_role\_arns](#output\_github\_aws\_iam\_oidc\_role\_arns) | The ARN of the IAM role that allows GitHub to assume it |
<!-- END_TF_DOCS -->