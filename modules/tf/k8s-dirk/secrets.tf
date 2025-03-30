resource "kubernetes_secret" "dirk_config" {
  metadata {
    name      = local.config_name
    namespace = var.namespace
  }

  data = {
    "dirk.yml" = yamlencode({
      log-level : "trace",
      server : {
        id : var.uid,
        name : var.name,
        listen-address : "0.0.0.0:13141",
        rules : {
          admin-ips : ["127.0.0.1"]
        }
      },
      certificates : {
        ca-cert : "file:///config/certs/dirk_authority.crt",
        server-cert : "file:///config/certs/dirk.crt",
        server-key : "file:///config/certs/dirk.key",
      },
      peers : yamldecode(var.peers),
      permissions : yamldecode(var.permissions),
      metrics : {
        listen-address : "0.0.0.0:8081"
      }
      stores : [
        {
          name : "Local"
          type : "filesystem"
          location : "/data/wallets"
        }
      ]
      storage-path : "/data/protection"
      unlocker : {
        // account-passphrases is a list of passphrases that can be used to unlock wallets
        account-passphrases : [
          "file:///config/passphrases/account-passphrase.txt"
        ]
        # wallet-passphrases : [
        #   "file:///config/passphrases/wallet-passphrase.txt"
        # ]
      }
      process : {
        // generation-passphrase is the passphrase used to encrypt newly generated accounts
        generation-passphrase : "file:///config/passphrases/account-passphrase.txt"
      }
    })
  }
}


resource "kubernetes_secret" "dirk_certs" {
  metadata {
    name      = local.certs_name
    namespace = var.namespace
  }

  data = {
    "dirk.crt" = file(var.dirk_crt)
    "dirk.key" = file(var.dirk_key)
  }
}
