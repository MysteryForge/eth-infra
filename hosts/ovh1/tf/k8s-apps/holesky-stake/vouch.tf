module "vouch0" {
  source         = "${var.modules_pth}/k8s-vouch"
  name           = "vouch0"
  dirk_authority = kubernetes_secret.dirk_authority.metadata.0.name
  vouch_key      = "${path.module}/config/certs/vouch0.key"
  vouch_crt      = "${path.module}/config/certs/vouch0.crt"
  namespace      = kubernetes_namespace.holesky_stake.metadata.0.name
  beacon_node_addresses = yamlencode([
    "http://geth-lighthouse.holesky-eth-nodes.svc:3500"
  ])
  graffiti = "MysteryForge"
  blockrelay_config = jsonencode({
    fee_recipient : var.vouch_fee_recipient,
    gas_limit : 30000000,
    relays : {
      "https://boost-relay-holesky.flashbots.net/" : {
        public_key : "0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110"
      }
    }
  })
  fallback_fee_recipient = var.vouch_fallback_fee_recipient
  dirk_endpoints = yamlencode([
    "dirk0:13141"
  ])
  wallets = yamlencode([
    "wallet0"
  ])
}
