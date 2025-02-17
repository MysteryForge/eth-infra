resource "kubernetes_namespace" "holesky_stake" {
  metadata {
    name = "holesky-stake"
  }
}
