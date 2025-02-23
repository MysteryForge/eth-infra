resource "kubernetes_manifest" "holesky_eigenda_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "operator-metrics"
      namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
      labels = {
        name = "operator"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          name = "operator"
        }
      }
      endpoints = [
        {
          port = "metrics"
          path = "/metrics"
        }
      ]
    }
  }
}
