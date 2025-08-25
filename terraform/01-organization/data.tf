data "tls_certificate" "certificate" {
  url = "https://github.com"
}

data "aws_organizations_organization" "this" {

}

data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket                 = "nova-devops-1-terraform-state"
    key                    = "management/00-bootstrap/terraform.tfstate"
    region                 = "eu-central-1"
    dynamodb_table         = "nova-devops-1-terraform-state-lock"
    skip_region_validation = true
  }
}