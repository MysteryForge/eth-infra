resource "kubernetes_namespace" "holesky_geth_lighthouse" {
  metadata {
    name = "holesky-geth-lighthouse"
  }
}

