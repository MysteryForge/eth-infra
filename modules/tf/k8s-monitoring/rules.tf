resource "kubernetes_manifest" "kubernetes_prometheus_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "kubernetes-prometheus-rules"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = yamldecode(file("${path.module}/rules/prometheus-rules.yaml"))
  }
}
