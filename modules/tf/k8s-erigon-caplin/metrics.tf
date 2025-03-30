resource "kubernetes_manifest" "metrics" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = local.name
      namespace = var.namespace
      labels = {
        name = local.name
      }
    }
    spec = {
      selector = {
        matchLabels = {
          name                 = local.name
          "eth-execution"      = "true"
          "eth-beacon"         = "true"
          "eth-execution-type" = "erigon"
          "eth-beacon-type"    = "caplin"
          "eth-network"        = var.eth_network
        }
      }
      endpoints = [
        {
          port = "erigon-metrics"
          path = "/debug/metrics/prometheus"
        }
      ]
    }
  }
}
