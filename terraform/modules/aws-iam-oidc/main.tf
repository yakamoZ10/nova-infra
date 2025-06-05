
# OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create ? 1 : 0
  client_id_list  = [var.github_org_url, "sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
  url             = "https://token.actions.githubusercontent.com"

  tags = merge({ Name = "GitHub OIDC Provider" }, var.default_tags)
}

## Policy for the OIDC

data "aws_iam_policy_document" "assume_role" {
  for_each = { for t in var.github_repositories : t.name => t }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      values   = ["repo:${each.value.name}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }

    condition {
      test     = "StringLike"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
      type        = "Federated"
    }
  }

  version = "2012-10-17"
}

resource "aws_iam_role" "this" {
  for_each = { for t in var.github_repositories : t.name => t }

  name                 = "github-${split("/", each.value.name)[1]}-role-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role[each.key].json
  description          = "Role assumed by the GitHub OIDC provider."
  max_session_duration = 3600
  path                 = "/"
}

resource "aws_iam_policy" "this" {
  for_each = { for t in var.github_repositories : t.name => t }

  name        = "github-${split("/", each.value.name)[1]}-policy-${var.environment}"
  description = "Policy used by the GitHub role."
  path        = "/"
  policy      = jsonencode(each.value.policy)
}

resource "aws_iam_policy_attachment" "this" {
  for_each = { for t in var.github_repositories : t.name => t }

  name       = "github-${split("/", each.value.name)[1]}-policy-attachment"
  roles      = [aws_iam_role.this[each.key].name]
  policy_arn = aws_iam_policy.this[each.key].arn
}