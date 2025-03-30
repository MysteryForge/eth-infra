resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = toset([
    "dashboards/geth.json",
    "dashboards/lighthouse.json",
  ])

  metadata {
    name      = "grafana-dashboards-${replace(each.key, "/", "-")}"
    namespace = kubernetes_namespace.holesky_eth_nodes.metadata.0.name
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
