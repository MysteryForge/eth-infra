resource "helm_release" "cloudnative-pg" {
  name       = "cloudnative-pg"
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = "0.22.1"
  namespace  = kubernetes_namespace.cloudnative_pg.metadata[0].name
  wait       = true
}
