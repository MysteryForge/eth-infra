resource "kubernetes_stateful_set" "geth_lighthouse" {
  # this prevents terraform from waiting for the statefulset to be readyconnection {
  wait_for_rollout = false

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
        termination_grace_period_seconds = 120
        image_pull_secrets {
          name = "ghcr-secret"
        }
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
            secret_name = kubernetes_secret.jwtsecret.metadata[0].name
          }
        }
        container {
          name              = "geth"
          image             = var.geth_image
          image_pull_policy = "IfNotPresent"
          args              = var.geth_args
          dynamic "liveness_probe" {
            for_each = var.enable_probes ? [1] : []
            content {
              failure_threshold = 3
              http_get {
                path   = "/"
                port   = 8545
                scheme = "HTTP"
              }
              initial_delay_seconds = 60
              period_seconds        = 60
              success_threshold     = 1
              timeout_seconds       = 5
            }
          }
          dynamic "readiness_probe" {
            for_each = var.enable_probes ? [1] : []
            content {
              failure_threshold = 3
              http_get {
                path   = "/"
                port   = 3031
                scheme = "HTTP"
              }
              period_seconds    = 10
              success_threshold = 1
              timeout_seconds   = 5
            }
          }
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

        dynamic "container" {
          for_each = var.enable_probes ? [1] : []
          content {
            name              = "geth-probe"
            image             = "ghcr.io/mysteryforge/eth-kit/execution-probe:d536b1c"
            image_pull_policy = "IfNotPresent"
            args = [
              "--addr",
              "0.0.0.0",
              "--port",
              "3031",
              "--metrics-addr",
              "0.0.0.0",
              "--metrics-port",
              "3001",
              "--node-uri",
              "http://localhost:8545",
              "--min-peers",
              "${var.geth_min_peers}",
            ]
            port {
              name           = "geth-probe"
              container_port = 3031
              protocol       = "TCP"
            }
          }
        }
        container {
          name              = "lighthouse"
          image             = var.lighthouse_image
          image_pull_policy = "IfNotPresent"
          args              = var.lighthouse_args
          dynamic "liveness_probe" {
            for_each = var.enable_probes ? [1] : []
            content {
              failure_threshold = 3
              http_get {
                path   = "/eth/v1/node/health"
                port   = 3500
                scheme = "HTTP"
              }
              initial_delay_seconds = 60
              period_seconds        = 60
              success_threshold     = 1
              timeout_seconds       = 5
            }
          }
          dynamic "readiness_probe" {
            for_each = var.enable_probes ? [1] : []

            content {
              failure_threshold = 3
              http_get {
                path   = "/"
                port   = 3032
                scheme = "HTTP"
              }
              period_seconds    = 10
              success_threshold = 1
              timeout_seconds   = 5
            }
          }
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

        dynamic "container" {
          for_each = var.enable_probes ? [1] : []
          content {
            name              = "lighthouse-probe"
            image             = "ghcr.io/mysteryforge/eth-kit/beacon-probe:d536b1c"
            image_pull_policy = "IfNotPresent"
            args = [
              "--addr",
              "0.0.0.0",
              "--port",
              "3032",
              "--metrics-addr",
              "0.0.0.0",
              "--metrics-port",
              "3002",
              "--node-uri",
              "http://localhost:3500",
            ]
            port {
              name           = "beacon-probe"
              container_port = 3032
              protocol       = "TCP"
            }
          }
        }
      }
    }
  }
}
