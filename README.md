# Astra MVP - Requirements

1. Define AWS landing zone design, organization units and aws accounts
2. Infrastructure should follow a multi account strategy
3. AWS Organizations should be used for centralizing account management
4. Identity Center should be used to centralize identity and access management across AWS Organization
5. Define Service Control Policies that need to be implemented
6. Define Tag Policies that need to be implemented
7. All infrastructure configurations need to be defined with Terraform
8. Use reusable terraform modules whenever you can
9. Isolate terraform state and reduce blast radius as much as possible
10. For state management, you have two options:
    - Use S3 buckets and DynamoDB for remote state management and locking
    - Use Terraform Cloud workspaces (op)
11. GitHub Actions should be used for building and pushing docker images to Docker registry
12. AWS ECR should be used as a docker container registry
13. Define recommended IaC code and project/module structure
14. Use AWS IAM Identity Provider and IAM Roles to establish integration with GitHub actions to use dynamic credentials.
15. Use AWS IAM Identity Provider and IAM Roles to establish integration with Terraform Cloud organization to use dynamic credentials.
16. Use shared github workflows
