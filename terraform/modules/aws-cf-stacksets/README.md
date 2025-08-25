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
| [aws_cloudformation_stack_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_instances) | resource |
| [aws_cloudformation_stack_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_units.root_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_units) | data source |
| [tls_certificate.certificate](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_stack_set"></a> [cf\_stack\_set](#input\_cf\_stack\_set) | List of CloudFormation StackSets to deploy | `list(any)` | `[]` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Tags | `map(string)` | n/a | yes |
| <a name="input_target_ou_names"></a> [target\_ou\_names](#input\_target\_ou\_names) | List of target Organization Units | `list(string)` | <pre>[<br/>  "Infrastructure",<br/>  "Workloads"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stack_set_names"></a> [stack\_set\_names](#output\_stack\_set\_names) | Names of all CloudFormation StackSets created |
<!-- END_TF_DOCS -->