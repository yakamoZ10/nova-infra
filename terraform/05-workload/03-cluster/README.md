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
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_tags"></a> [default\_tags](#module\_default\_tags) | ../../modules/default-tags | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../../modules/eks | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.default](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/resources/kms_key) | resource |
| [aws_caller_identity.default](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/5.97.0/docs/data-sources/iam_policy_document) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | `"dev"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->