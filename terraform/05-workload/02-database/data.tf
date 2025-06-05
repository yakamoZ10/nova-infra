data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "nova-devops-1-terraform-state"
    key    = "network/03-shared-networking/terraform.tfstate"
    region = "eu-central-1"
    # skip_region_validation = true
    dynamodb_table = "nova-devops-1-terraform-state-lock"
  }
}
