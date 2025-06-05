data "tls_certificate" "tfc_certificate" {
    url = var.github_org_url
}