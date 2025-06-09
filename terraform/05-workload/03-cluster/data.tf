data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nova-devops-1-terraform-state"
    key    = "network/03-networking/terraform.tfstate"
    region = "eu-central-1"
  }
}