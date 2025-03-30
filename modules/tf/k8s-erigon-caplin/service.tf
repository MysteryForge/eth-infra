resource "kubernetes_service" "erigon_caplin" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name                 = local.name
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "erigon"
      "eth-beacon-type"    = "caplin"
      "eth-network"        = var.eth_network
    }
  }
  spec {
    port {
      name        = "erigon-http"
      port        = 8545
      target_port = "erigon-http"
      protocol    = "TCP"
    }
    port {
      name        = "erigon-ws"
      port        = 8546
      target_port = "erigon-ws"
      protocol    = "TCP"
    }
    port {
      name        = "erigon-authrpc"
      port        = 8551
      target_port = "erigon-authrpc"
      protocol    = "TCP"
    }
    port {
      name        = "erigon-metrics"
      port        = 6060
      target_port = "erigon-metrics"
      protocol    = "TCP"
    }
    port {
      name        = "beacon-http"
      port        = 3500
      target_port = "beacon-http"
      protocol    = "TCP"
    }
    port {
      name        = "beacon-metrics"
      port        = 6061
      target_port = "beacon-metrics"
      protocol    = "TCP"
    }

    selector = {
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "erigon"
      "eth-beacon-type"    = "caplin"
      "eth-network"        = var.eth_network
      name                 = local.name
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}
