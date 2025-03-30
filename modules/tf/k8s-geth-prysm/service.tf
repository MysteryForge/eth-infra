resource "kubernetes_service" "geth_prysm" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name                 = local.name
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "prysm"
      "eth-network"        = var.eth_network
    }
  }
  spec {
    port {
      name        = "geth-http"
      port        = 8545
      target_port = "geth-http"
      protocol    = "TCP"
    }
    port {
      name        = "geth-ws"
      port        = 8546
      target_port = "geth-ws"
      protocol    = "TCP"
    }
    port {
      name        = "geth-authrpc"
      port        = 8551
      target_port = "geth-authrpc"
      protocol    = "TCP"
    }
    port {
      name        = "geth-metrics"
      port        = 6060
      target_port = "geth-metrics"
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
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "prysm"
      "eth-network"        = var.eth_network
      name                 = local.name
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}
