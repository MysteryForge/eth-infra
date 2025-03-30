module "dirk0" {
  source             = "${var.modules_pth}/k8s-dirk"
  uid                = 1000
  name               = "dirk0"
  dirk_crt           = "${path.module}/config/certs/dirk0.crt"
  dirk_key           = "${path.module}/config/certs/dirk0.key"
  namespace          = kubernetes_namespace.holesky_stake.metadata.0.name
  dirk_authority     = kubernetes_secret.dirk_authority.metadata.0.name
  wallet_passphrase  = kubernetes_secret.wallet_passphrase.metadata.0.name
  account_passphrase = kubernetes_secret.account_passphrase.metadata.0.name
  wallet_name        = "wallet0"
  wallet_type        = "nd"
  peers = yamlencode({
    "1000" : "dirk0:13141"
  })
  permissions = yamlencode({
    "vouch0" : {
      "wallet0" : "All"
    }
  })
}
