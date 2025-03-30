resource "kubernetes_stateful_set" "erigon_caplin" {
  # this prevents terraform from waiting for the statefulset to be readyconnection {
  wait_for_rollout = false

  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name                 = local.name
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "erigon"
      "eth-beacon-type"    = "caplin"
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
          "eth-execution-type" = "erigon"
          "eth-beacon-type"    = "caplin"
          "eth-network"        = var.eth_network
        }
      }

      spec {
        termination_grace_period_seconds = 120
        image_pull_secrets {
          name = "ghcr-secret"
        }
        volume {
          name = "erigon"
          persistent_volume_claim {
            claim_name = local.erigon_pvc_name
          }
        }
        volume {
          name = "jwtsecret"
          secret {
            secret_name = kubernetes_secret.jwtsecret.metadata[0].name
          }
        }
        init_container {
          name              = "erigon-init"
          image             = "alpine:3.20"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -ex
            chown -R 1000:1000 /data/erigon
            chmod -R 750 /data/erigon
            EOF
          ]
          volume_mount {
            name              = "erigon"
            mount_path        = "/data/erigon"
            mount_propagation = "None"
          }
        }
        container {
          name              = "erigon"
          image             = var.erigon_image
          image_pull_policy = "IfNotPresent"
          args = concat(
            [
              "--datadir=/data/erigon",
              "--port=14580",
              "--http",
              "--http.addr=0.0.0.0",
              "--http.port=8545",
              "--http.vhosts=*",
              "--ws",
              "--ws.port=8546",
              "--metrics",
              "--metrics.addr=0.0.0.0",
              "--metrics.port=6060",
              "--authrpc.jwtsecret=/jwtsecret",
              "--authrpc.addr=0.0.0.0",
              "--authrpc.port=8551",
              "--authrpc.vhosts=*",
              "--caplin.enable-upnp",
              "--caplin.discovery.addr=0.0.0.0",
              "--caplin.discovery.port=4000",
              "--caplin.discovery.tcpport=4001",
              "--beacon.api=beacon,builder,config,debug,events,node,validator,lighthouse",
              "--beacon.api.addr=0.0.0.0",
              "--beacon.api.port=3500",
              "--beacon.api.cors.allow-origins=*"
            ],
            var.erigon_args
          )
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
            name           = "erigon-disc"
            container_port = 14580
            protocol       = "TCP"
          }
          port {
            name           = "erigon-p2p"
            container_port = 14580
            protocol       = "TCP"
          }
          port {
            name           = "erigon-http"
            container_port = 8545
            protocol       = "TCP"
          }
          port {
            name           = "erigon-ws"
            container_port = 8546
            protocol       = "TCP"
          }
          port {
            name           = "erigon-metrics"
            container_port = 6060
            protocol       = "TCP"
          }
          port {
            name           = "erigon-authrpc"
            container_port = 8551
            protocol       = "TCP"
          }
          volume_mount {
            name       = "erigon"
            mount_path = "/data/erigon"
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
            name              = "erigon-probe"
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
              "${var.erigon_min_peers}",
            ]
            port {
              name           = "erigon-probe"
              container_port = 3031
              protocol       = "TCP"
            }
          }
        }
      }
    }
  }
}
