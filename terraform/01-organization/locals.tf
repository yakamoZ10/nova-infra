locals {
  org_ous = [
    { name = "Infrastructure", parent_id = "root" },
    { name = "Suspended", parent_id = "root" },
    { name = "Policy Staging", parent_id = "root" },
    { name = "Workloads", parent_id = "root" },
    { name = "DEV", parent_id = "Workloads" },
    { name = "TEST", parent_id = "Workloads" },
    { name = "UAT", parent_id = "Workloads" },
    { name = "PROD", parent_id = "Workloads" }
  ]

  aws_accounts = [
    {
      name      = "nova-devops-1-dev"
      email     = "tali+astra-devops-1-dev@appstellar.academy"
      parent_id = "DEV"
      tags = merge(module.tags.default_tags, {
        Name        = "astra-devops-1-dev"
        Environment = "dev"
        OU          = "DEV"
      })
    },
    {
      name      = "nova-devops-1-network"
      email     = "tali+astra-devops-1-network@appstellar.academy"
      parent_id = "Infrastructure"
      tags = merge(module.tags.default_tags, {
        Name        = "astra-devops-1-network"
        Environment = "shared"
        OU          = "Infrastructure"
      })
    },
    {
      name      = "nova-devops-1-shared-services"
      email     = "tali+astra-devops-1-shared-services@appstellar.academy"
      parent_id = "Infrastructure"
      tags = merge(module.tags.default_tags, {
        Name        = "astra-devops-1-shared-services"
        Environment = "shared"
        OU          = "Infrastructure"
      })
    },
    {
      name      = "nova-devops-1-prod"
      email     = "tali+astra-devops-1-prod@appstellar.academy"
      parent_id = "PROD"
      tags = merge(module.tags.default_tags, {
        Name        = "nova-devops-1-prod"
        Environment = "prod"
        OU          = "PROD"
      })
    }
  ]
}