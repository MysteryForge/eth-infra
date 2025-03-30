resource "helm_release" "dex" {
  name       = "dex"
  repository = "https://charts.dexidp.io"
  chart      = "dex"
  version    = "0.19.1"
  namespace  = kubernetes_namespace.oidc.metadata[0].name
  values = [yamlencode({
    config = {
      issuer = local.issuer
      storage = {
        type = "memory"
      }
      enablePasswordDB = false
      connectors = [{
        type = "github"
        id   = "github"
        name = "GitHub"
        config = {
          clientID     = var.github_client_id
          clientSecret = var.github_client_secret
          redirectURI  = local.redirect_uri
          orgs = [{
            name = var.org_name
          }]
          teamNameField = "slug"
        }
      }]
      staticClients = [
        {
          id     = "grafana"
          name   = "Grafana"
          secret = var.oidc_grafana_secret
          redirectURIs = [
            local.grafana_redirect_uri
          ]
        },
      ]
    }
    ingress = {
      enabled   = true
      className = "nginx"
      hosts = [{
        host  = local.ingress_host
        paths = [{ pathType = "Prefix", path = "/" }]
      }]
      tls = [{
        secretName = "dex-tls"
        hosts      = [local.ingress_host]
      }]
    }
    serviceMonitor = {
      enable = true
    }
  })]
}
