
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "8.3.9"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  wait       = true
  values = [yamlencode({
    logLevel = "debug"
    provider = "cloudflare"
    rbac = {
      create = true
    }
    metrics = {
      enabled = true
      serviceMonitor = {
        enabled = true
      }
    }
  })]

  set_sensitive {
    name  = "cloudflare.apiToken"
    value = var.cloudflare_api_token
    type  = "string"
  }
}
