resource "kubernetes_config_map" "holesky_eigenda_grafana_dashboards" {
  for_each = toset([
    "dashboards/common-metrics-global.json",
    "dashboards/common-metrics.json",
    "dashboards/eigenda-metrics.json",
  ])

  metadata {
    name      = "grafana-dashboards-${replace(each.key, "/", "-")}"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      "grafana_dashboard" = "1"
    }
    annotations = {
      "dashboards" = "k8s"
    }
  }

  data = {
    replace("${each.key}", "/", "-") = file("${each.key}")
  }
}
