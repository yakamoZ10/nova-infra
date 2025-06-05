resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "controltower.amazonaws.com",
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ram.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]

  feature_set = "ALL"
}


resource "aws_organizations_organizational_unit" "parent_ous" {
  for_each = {
    for ou in var.org_ous : ou.name => ou
    if ou.parent_id == "root"
  }
  name      = each.value.name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "child_ous" {
  for_each = {
    for ou in var.org_ous : ou.name => ou
    if ou.parent_id != "root"
  }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.parent_ous[each.value.parent_id].id
}

resource "aws_organizations_account" "this" {
  for_each = {
    for account in var.aws_accounts : account.name => account
  }
  name              = each.key
  email             = each.value.email
  parent_id         = try(aws_organizations_organizational_unit.parent_ous[each.value.parent_id].id, aws_organizations_organizational_unit.child_ous[each.value.parent_id].id)
  close_on_deletion = each.value.close_on_deletion
  tags              = each.value.tags
}
