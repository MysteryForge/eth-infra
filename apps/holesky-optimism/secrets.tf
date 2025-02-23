resource "kubernetes_manifest" "holesky_op_secrets" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "op-secrets"
      namespace = kubernetes_namespace.holesky_op.metadata[0].name
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "doppler-secret-store"
      }
      refreshInterval = "3m"
      target = {
        name = "op-secrets"
      }
      data = [
        {
          secretKey = "SEQUENCER_PRIVATE_KEY"
          remoteRef = {
            key = "SEQUENCER_PRIVATE_KEY"
          }
        },
        {
          secretKey = "BATCHER_PRIVATE_KEY"
          remoteRef = {
            key = "BATCHER_PRIVATE_KEY"
          }
        },
        {
          secretKey = "PROPOSER_PRIVATE_KEY"
          remoteRef = {
            key = "PROPOSER_PRIVATE_KEY"
          }
        },
        {
          secretKey = "L2_OUTPUT_ORACLE_PROXY"
          remoteRef = {
            key = "L2_OUTPUT_ORACLE_PROXY"
          }
        },
        {
          secretKey = "GENESIS_URL"
          remoteRef = {
            key = "L2_GENESIS_URL"
          }
        },
        {
          secretKey = "ROLLUP_URL"
          remoteRef = {
            key = "L2_ROLLUP_URL"
          }
        },
        {
          secretKey = "NETWORK_ID"
          remoteRef = {
            key = "L2_NETWORK_ID"
          }
        }
      ]
    }
  }
}
