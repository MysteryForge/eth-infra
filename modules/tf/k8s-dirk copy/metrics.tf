resource "kubernetes_manifest" "dirk_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = local.metrics_name
      namespace = var.namespace
      labels = {
        name = local.metrics_name
      }
    }
    spec = {
      selector = {
        matchLabels = {
          name = local.svc_name
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
