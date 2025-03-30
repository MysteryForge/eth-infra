locals {
  issuer               = format("https://auth.%s", var.issuer_host)
  ingress_host         = format("auth.%s", var.issuer_host)
  grafana_redirect_uri = format("https://grafana.%s/login/generic_oauth", var.issuer_host)
  redirect_uri         = format("%s/callback", local.issuer)
}

resource "kubernetes_namespace" "oidc" {
  metadata {
    name = "oidc"
  }
}
