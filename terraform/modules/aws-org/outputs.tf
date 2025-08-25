output "parent_org_ou_arns" {
  value = { for ou in var.org_ous : ou.name => aws_organizations_organizational_unit.parent_ous[ou.name].arn if ou.parent_id == "root" }
}

output "child_org_ou_arns" {
  value = { for ou in var.org_ous : ou.name => aws_organizations_organizational_unit.child_ous[ou.name].arn if ou.parent_id != "root" }
}

output "aws_accounts" {
  value = merge(
    { "${aws_organizations_organization.this.master_account_name}" = "" },
    { for account in aws_organizations_account.this : account.name => account.id }
  )
}

output "aws_account_ids" {
  value = concat([aws_organizations_organization.this.master_account_id], [for account in aws_organizations_account.this : account.id])
}