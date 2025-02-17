resource "random_string" "jwtsecret" {
  length           = 64
  special          = true
  override_special = "abcdef"
  lower            = false
  upper            = false
}

resource "kubernetes_secret" "jwtsecret" {
  metadata {
    name      = local.jwt_name
    namespace = var.namespace
  }

  data = {
    "jwtsecret" = sensitive(random_string.jwtsecret.result)
  }
}
