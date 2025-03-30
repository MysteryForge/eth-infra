
resource "kubernetes_secret" "doppler_secret_token" {
  metadata {
    name      = "doppler-token-secret"
    namespace = "default"
  }
  data = {
    serviceToken = var.doppler_token
  }
}

resource "kubernetes_manifest" "doppler_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "doppler-secret-store"
    }
    spec = {
      provider = {
        doppler = {
          auth = {
            secretRef = {
              dopplerToken = {
                namespace = "default"
                name      = kubernetes_secret.doppler_secret_token.metadata[0].name
                key       = "serviceToken"
              }
            }
          }
        }
      }
    }
  }
}

