# Terraform state file to remote (S3 Bucket)
terraform {
  backend "s3" {
    bucket                 = "nova-devops-1-terraform-state"
    key                    = "database/05-workload/02-database/terraform.tfstate"
    region                 = "eu-central-1"
    skip_region_validation = true
    dynamodb_table         = "nova-devops-1-terraform-state-lock"
  }
}