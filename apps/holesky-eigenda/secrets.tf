resource "kubernetes_manifest" "holesky_eigenda_ecdsa" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "eigenda-ecdsa"
      namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "eigenda-ecdsa"
      }
      data = [
        {
          secretKey = "ecdsa"
          remoteRef = {
            key = "EIGENDA_OPERATOR_ECDSA"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "holesky_eigenda_bls" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "eigenda-bls"
      namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "eigenda-bls"
      }
      data = [
        {
          secretKey = "bls"
          remoteRef = {
            key = "EIGENDA_OPERATOR_BLS"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "holesky_eigenda" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "eigenda"
      namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "eigenda"
      }
      data = [
        {
          secretKey = "NODE_HOSTNAME"
          remoteRef = {
            key = "EIGENDA_NODE_HOSTNAME"
          }
        }
      ]
    }
  }
}
