resource "kubernetes_namespace" "cloudnative_pg" {
  metadata {
    name = "cloudnative-pg"
  }
}
