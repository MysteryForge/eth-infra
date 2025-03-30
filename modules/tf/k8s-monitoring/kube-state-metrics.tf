resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.27.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true
  values = [
    yamlencode({
      prometheus = {
        monitor = {
          enabled     = true
          honorLabels = true
        }
      }
    })
  ]
}

