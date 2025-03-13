resource "kubernetes_manifest" "holesky_geth_lighthouse_ingress_basic_auth" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ingress-basic-auth"
      namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "ingress-basic-auth"
      }
      data = [
        {
          secretKey = "auth"
          remoteRef = {
            key = "HOLESKY_NODE_AUTH"
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "holesky_geth_lighthouse_ingress_basic_auth" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "geth-lighthouse"
      namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "geth-lighthouse"
      }
      data = [
        {
          secretKey = "SUGGESTED_FEE_RECIPIENT"
          remoteRef = {
            key = "HOLESKY_SUGGESTED_FEE_RECIPIENT"
          }
        },
      ]
    }
  }
}
