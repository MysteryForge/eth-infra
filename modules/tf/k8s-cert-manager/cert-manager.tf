resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.3"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [
    yamlencode({
      podDnsPolicy = "None"
      podDnsConfig = {
        nameservers = [
          "1.1.1.1"
        ]
      }
      extraArgs = [
        "--dns01-recursive-nameservers-only"
      ]
    })
  ]
  set {
    name  = "prometheus.servicemonitor.enabled"
    value = true
  }
}

resource "kubernetes_secret" "cloudflare_issuer_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    api-token = var.cloudflare_api_token
  }
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-prod-issuer-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                email = var.cloudflare_email
                apiTokenSecretRef = {
                  name = kubernetes_secret.cloudflare_issuer_token.metadata[0].name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

