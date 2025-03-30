resource "kubernetes_manifest" "ingress_basic_auth" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ingress-basic-auth"
      namespace = kubernetes_namespace.holesky_eth_nodes.metadata[0].name
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
