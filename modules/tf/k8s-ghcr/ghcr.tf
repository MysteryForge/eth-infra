resource "kubernetes_secret" "ghcr_secret" {
  metadata {
    name      = "ghcr-secret"
    namespace = "default"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-auto-enabled" = "true",
      "reflector.v1.k8s.emberstack.com/reflection-allowed"      = "true"
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          "auth" = var.ghcr_token
        }
      }
    })
  }
}

