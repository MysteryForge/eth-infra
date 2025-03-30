resource "kubernetes_namespace" "holesky_eth_nodes" {
  metadata {
    name = "holesky-eth-nodes"
  }
}

