locals {
  group_membership = flatten([
    for group_name, group in var.groups : [
      for user in group.users : {
        groupname = group_name
        username  = user
      }
    ]
  ])

  name_to_id = {
    for account in data.aws_organizations_organization.this.accounts :
    account.name => account.id
  }

  all_assignments = flatten([
    for assignment in var.assignments : [
      for account_name in assignment.account_names : {
        account_id          = lookup(local.name_to_id, account_name, null)
        permission_set_name = assignment.permission_set_name
        principal_name      = assignment.principal_name
      }
    ]
  ])

  all_policy_attachments = flatten([
    for p in var.permission_sets : [
      for policy in p.managed_policies : {
        permission_set_name = p.name
        policy_arn          = policy
      }
    ]
  ])
}

resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  user_name         = each.key
  display_name      = "${each.value.first_name} ${each.value.last_name}"

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}

resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.key
  description       = each.value.description
}

resource "aws_identitystore_group_membership" "this" {
  for_each = { for gm in local.group_membership : "${gm.username}-${gm.groupname}" => gm }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.this[each.value.groupname].group_id
  member_id         = aws_identitystore_user.this[each.value.username].user_id
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = { for permission in var.permission_sets : permission.name => permission }

  name             = each.value.name
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for a in local.all_assignments : "${a.permission_set_name}-${a.principal_name}-${a.account_id}" => a }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
  principal_id       = aws_identitystore_group.this[each.value.principal_name].group_id
  principal_type     = "GROUP"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = { for p in local.all_policy_attachments :
  "${p.permission_set_name}-${p.policy_arn}" => p }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
  managed_policy_arn = each.value.policy_arn

  depends_on = [aws_ssoadmin_account_assignment.this]
}

