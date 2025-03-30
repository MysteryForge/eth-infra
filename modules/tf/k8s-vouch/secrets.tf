resource "kubernetes_secret" "vouch_certs" {
  metadata {
    name      = local.certs_name
    namespace = var.namespace
  }

  data = {
    "vouch.key" = file(var.vouch_key)
    "vouch.crt" = file(var.vouch_crt)
  }
}

resource "kubernetes_secret" "vouch_config" {
  metadata {
    name      = local.config_name
    namespace = var.namespace
  }

  data = {
    "vouch.yml" = yamlencode({
      log-level : "trace",
      beacon-node-addresses : yamldecode(var.beacon_node_addresses)
      metrics : {
        prometheus : {
          listen-address : "0.0.0.0:8081"
        }
      }
      graffiti : {
        static : var.graffiti
      }
      blockrelay : {
        config : {
          url : "file:///config/blockrelay.json"
        }
        fallback-fee-recipient : var.fallback_fee_recipient
        fallback-gas-limit : 30000000
      }
      accountmanager : {
        dirk : {
          endpoints : yamldecode(var.dirk_endpoints)
          client-cert : "file:///config/certs/vouch.crt"
          client-key : "file:///config/certs/vouch.key"
          ca-cert : "file:///config/certs/dirk_authority.crt"
          accounts : yamldecode(var.wallets)
        }
      }
    })
  }
}

resource "kubernetes_secret" "blockrelay" {
  metadata {
    name      = local.blockrelay_name
    namespace = var.namespace
  }

  data = {
    "blockrelay.json" = var.blockrelay_config
  }
}
