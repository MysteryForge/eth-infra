resource "random_string" "jwtsecret" {
  length           = 64
  special          = true
  override_special = "abcdef"
  lower            = false
  upper            = false
}

resource "kubernetes_secret" "jwtsecret" {
  metadata {
    name      = "jwtsecret"
    namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
  }

  data = {
    "jwtsecret" = sensitive(random_string.jwtsecret.result)
  }
}
