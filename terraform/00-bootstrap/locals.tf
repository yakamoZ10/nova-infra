locals {
  project        = "nova-infra"
  github_org_url = "https://github.com/yakamoZ10"

  github_repositories = [
    {
      name = "yakamoZ10/nova-infra"
      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "*"
            ]
            Effect   = "Allow"
            Resource = "*"
          }

        ]
      }

    },
    {
      name : "yakamoZ10/nova-api",
      policy : {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "ecr:Describe*",
              "ecr:Get*",
              "ecr:List*",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:BatchCheckLayerAvailability",
              "ecr:PutImage",
              "ecr:BatchImportUpstreamImage",
              "ecr:BatchGetImage",
              "ecr:InitiateLayerUpload",
              "ssm:PutParameter",
              "ssm:SendCommand",
              "elasticloadbalancing:*",
              "secretsmanager:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      }
    },
    {
      name : "yakamoZ10/nova-web",
      policy : {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "ecr:Describe*",
              "ecr:Get*",
              "ecr:List*",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:BatchCheckLayerAvailability",
              "ecr:PutImage",
              "ecr:BatchImportUpstreamImage",
              "ecr:BatchGetImage",
              "ecr:InitiateLayerUpload",
              "ssm:SendCommand",
              "elasticloadbalancing:*",
              "secretsmanager:*"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      }
    }
  ]
  default_tags = {
    Project  = local.project
    Training = "devops-engineer-associate"
  }
}