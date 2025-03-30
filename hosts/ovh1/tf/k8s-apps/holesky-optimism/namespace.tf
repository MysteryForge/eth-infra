resource "kubernetes_namespace" "holesky_op" {
  metadata {
    name = "holesky-optimism"
  }
}

