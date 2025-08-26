terraform {
  backend "s3" {
    bucket                 = "nova-devops-1-terraform-state"
    key                    = "management/00-bootstrap/terraform.tfstate"
    region                 = "eu-central-1"
    skip_region_validation = true
    dynamodb_table         = "nova-devops-1-terraform-state-lock"
  }
}


