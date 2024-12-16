resource "kubernetes_secret" "dirk_authority" {
  metadata {
    name      = "dirk-authority"
    namespace = kubernetes_namespace.holesky_stake.metadata.0.name
  }

  data = {
    "dirk_authority.crt" = file("${path.module}/config/certs/dirk_authority.crt")
    "dirk_authority.key" = file("${path.module}/config/certs/dirk_authority.key")
  }
}



resource "kubernetes_secret" "wallet_passphrase" {
  metadata {
    name      = "wallet-passphrase"
    namespace = kubernetes_namespace.holesky_stake.metadata.0.name
  }

  data = {
    "wallet-passphrase.txt" = file("${path.module}/config/wallet-passphrase.txt")
  }
}

resource "kubernetes_secret" "account_passphrase" {
  metadata {
    name      = "account-passphrase"
    namespace = kubernetes_namespace.holesky_stake.metadata.0.name
  }

  data = {
    "account-passphrase.txt" = file("${path.module}/config/account-passphrase.txt")
  }
}
