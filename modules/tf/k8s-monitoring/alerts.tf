resource "kubernetes_manifest" "kubernetes_prometheus_alerts" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "kubernetes-prometheus-alerts"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = yamldecode(file("${path.module}/alerts/prometheus-alerts.yaml"))
  }
}
