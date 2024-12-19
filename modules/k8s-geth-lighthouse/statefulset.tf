resource "kubernetes_stateful_set" "geth_lighthouse" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name                 = local.name
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "lighthouse"
      "eth-network"        = var.eth_network
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = local.name
      }
    }
    service_name = local.name
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name                 = local.name
          "eth-execution"      = "true"
          "eth-beacon"         = "true"
          "eth-execution-type" = "geth"
          "eth-beacon-type"    = "lighthouse"
          "eth-network"        = var.eth_network
        }
      }

      spec {
        termination_grace_period_seconds = 320
        volume {
          name = "geth"
          persistent_volume_claim {
            claim_name = local.geth_pvc_name
          }
        }
        volume {
          name = "lighthouse"
          persistent_volume_claim {
            claim_name = local.lighthouse_pvc_name
          }
        }
        volume {
          name = "jwtsecret"
          secret {
            secret_name = kubernetes_secret.jwtsecret.metadata.0.name
          }
        }
        container {
          name              = "geth"
          image             = var.geth_image
          image_pull_policy = "IfNotPresent"
          args              = var.geth_args
          # resources { }
          port {
            name           = "geth-discovery"
            container_port = 14580
            protocol       = "TCP"
          }
          port {
            name           = "geth-p2p"
            container_port = 14580
            protocol       = "TCP"
          }
          port {
            name           = "geth-http"
            container_port = 8545
            protocol       = "TCP"
          }
          port {
            name           = "geth-ws"
            container_port = 8546
            protocol       = "TCP"
          }
          port {
            name           = "geth-metrics"
            container_port = 6060
            protocol       = "TCP"
          }
          port {
            name           = "geth-authrpc"
            container_port = 8551
            protocol       = "TCP"
          }
          volume_mount {
            name       = "geth"
            mount_path = "/data/geth"
          }
          volume_mount {
            name       = "jwtsecret"
            mount_path = "/jwtsecret"
            sub_path   = "jwtsecret"
          }
        }

        container {
          name              = "lighthouse"
          image             = var.lighthouse_image
          image_pull_policy = "IfNotPresent"
          args              = var.lighthouse_args
          port {
            name           = "beacon-http"
            container_port = 3500
            protocol       = "TCP"
          }
          port {
            name           = "beacon-metrics"
            container_port = 6061
            protocol       = "TCP"
          }
          volume_mount {
            name       = "lighthouse"
            mount_path = "/data/lighthouse"
            sub_path   = "lighthouse"
          }
          volume_mount {
            name       = "lighthouse"
            mount_path = "/data/lighthouse-blobs"
            sub_path   = "lighthouse-blobs"
          }
          volume_mount {
            name       = "jwtsecret"
            mount_path = "/jwtsecret"
            sub_path   = "jwtsecret"
          }
        }
      }
    }
  }
}
