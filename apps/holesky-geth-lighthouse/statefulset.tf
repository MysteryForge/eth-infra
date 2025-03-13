resource "kubernetes_stateful_set" "holesky_geth_lighthouse" {
  metadata {
    name      = "holesky-geth-lighthouse"
    namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    labels = {
      name                 = "node-huq"
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "lighthouse"
      "eth-network"        = "holesky"
      "eth-node-key"       = "node-huq"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "node-huq"
      }
    }
    service_name = "node-huq"
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name                 = "node-huq"
          "eth-execution"      = "true"
          "eth-beacon"         = "true"
          "eth-execution-type" = "geth"
          "eth-beacon-type"    = "lighthouse"
          "eth-network"        = "holesky"
          "eth-node-key"       = "node-huq"
        }
      }

      spec {
        image_pull_secrets {
          name = "ghcr-secret"
        }
        termination_grace_period_seconds = 600
        volume {
          name = "geth"
          persistent_volume_claim {
            claim_name = "node-huq-geth"
          }
        }
        volume {
          name = "lighthouse"
          persistent_volume_claim {
            claim_name = "node-huq-lighthouse"
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
          image             = "ethereum/client-go:v1.14.12"
          image_pull_policy = "IfNotPresent"
          args = [
            "--holesky",
            "--datadir=/data/geth",
            "--port=14580",
            "--discovery.port=14580",
            "--http",
            "--http.addr=0.0.0.0",
            "--http.port=8545",
            "--http.rpcprefix=/",
            "--http.vhosts=*",
            "--http.api=eth,net,engine,web3,debug,admin,les,txpool",
            "--ws",
            "--ws.addr=0.0.0.0",
            "--ws.port=8546",
            "--ws.origins=*",
            "--ws.rpcprefix=/",
            "--ws.api=eth,net,engine,web3,debug,txpool",
            "--metrics",
            "--metrics.addr=0.0.0.0",
            "--metrics.port=6060",
            "--authrpc.jwtsecret=/jwtsecret",
            "--authrpc.addr=0.0.0.0",
            "--authrpc.port=8551",
            "--authrpc.vhosts=*"
          ]
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
          image             = "sigp/lighthouse:v5.3.0"
          image_pull_policy = "IfNotPresent"
          args = [
            "lighthouse",
            "beacon_node",
            "--network=holesky",
            "--http",
            "--http-address=0.0.0.0",
            "--http-port=3500",
            "--datadir=/data/lighthouse",
            "--metrics",
            "--metrics-address=0.0.0.0",
            "--metrics-port=6061",
            "--metrics-allow-origin=*",
            "--execution-jwt=/jwtsecret",
            "--execution-endpoint=http://localhost:8551",
            "--checkpoint-sync-url=https://holesky.beaconstate.info",
            "--prune-blobs=false",
            "--blobs-dir=/data/lighthouse-blobs",
            "--suggested-fee-recipient=$SUGGESTED_FEE_RECIPIENT"
          ]
          env {
            name = "SUGGESTED_FEE_RECIPIENT"
            value_from {
              secret_key_ref {
                name = "geth-lighthouse"
                key  = "SUGGESTED_FEE_RECIPIENT"
              }
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
      }
    }
  }
}
