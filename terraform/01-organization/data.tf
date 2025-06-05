data "tls_certificate" "certificate" {
  url = "https://github.com"
}

data "aws_organizations_organization" "this" {

}

data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

