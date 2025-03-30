resource "helm_release" "node_exporter" {
  name       = "node-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = "4.42.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true
  skip_crds  = true

  values = [
    yamlencode({
      fullnameOverride = "node-exporter"
      prometheus = {
        monitor = {
          enabled  = true
          jobLabel = "node-exporter"
          relabelings = [{
            action       = "replace"
            sourceLabels = ["__meta_kubernetes_pod_node_name"]
            targetLabel  = "instance"
          }]
        }
      }
    })
  ]
}

