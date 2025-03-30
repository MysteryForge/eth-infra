resource "kubernetes_manifest" "holesky_eigenda_prometheus_alerts" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "prometheus-alerts"
      namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    }
    spec = yamldecode(file("${path.module}/alerts/eigenda-alerts.yaml"))
  }
}
