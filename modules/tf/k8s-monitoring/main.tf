locals {
  grafana_domain = format("grafana.%s", var.grafana_host)
  grafana_url    = format("https://%s", local.grafana_domain)
  auth_domain    = format("https://auth.%s", var.grafana_host)
}


resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
