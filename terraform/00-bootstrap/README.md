## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_oidc_roles"></a> [github\_oidc\_roles](#module\_github\_oidc\_roles) | ../terraform/modules/01-Identity_Provider_and_Role | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_oidc_roles"></a> [github\_oidc\_roles](#module\_github\_oidc\_roles) | ../modules/aws-iam-oidc | n/a |
| <a name="module_s3_backend"></a> [s3\_backend](#module\_s3\_backend) | ../modules/s3-backend | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_aws_iam_oidc_role_arns"></a> [github\_aws\_iam\_oidc\_role\_arns](#output\_github\_aws\_iam\_oidc\_role\_arns) | The ARN of the IAM role that allows GitHub to assume it |
<!-- END_TF_DOCS -->