resource "kubernetes_persistent_volume_claim" "holesky_op_geth" {
  metadata {
    name      = "op-geth"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name          = "op-geth"
      "eth-network" = "holesky"
      "eth-op-geth" = "true"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "25Gi"
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}

resource "kubernetes_stateful_set" "holesky_op_sequencer" {
  metadata {
    name      = "op-sequencer"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                                = "op-sequencer"
      "eth-network"      = "holesky"
      "eth-op-sequencer" = "true"
      "eth-op-node"      = "true"
      "eth-op-geth"      = "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "op-sequencer"
      }
    }
    service_name = "op-sequencer"
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name               = "op-sequencer"
          "eth-network"      = "holesky"
          "eth-op-sequencer" = "true"
          "eth-op-node"      = "true"
          "eth-op-geth"      = "true"
        }
      }
      spec {
        termination_grace_period_seconds = 60
        volume {
          name = "op-geth"
          persistent_volume_claim {
            claim_name = "op-geth"
          }
        }
        volume {
          name = "jwtsecret"
          secret {
            secret_name = kubernetes_secret.jwtsecret.metadata[0].name
          }
        }
        init_container {
          name              = "op-geth-init"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:v1.101408.0"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            apk add curl

            if [ ! -d "/data/geth" ]; then
              echo "downloading genesis.json"
              curl $GENESIS_URL > genesis.json
              echo "initializing geth data directory"
              head -n 10 ./genesis.json
              geth init --state.scheme=hash --datadir=/data ./genesis.json
            else
              echo "geth data directory already exists"
            fi
            EOF
          ]
          env {
            name = "GENESIS_URL"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "GENESIS_URL"
              }
            }
          }
          volume_mount {
            name              = "op-geth"
            mount_path        = "/data"
            mount_propagation = "None"
          }
        }
        container {
          name              = "op-geth"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:v1.101411.0"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            exec geth \
              --datadir=/data \
              --http \
              --http.corsdomain="*" \
              --http.vhosts="*" \
              --http.addr=0.0.0.0 \
              --http.port=8545 \
              --http.api=web3,debug,eth,txpool,net,engine,admin \
              --ws \
              --ws.addr=0.0.0.0 \
              --ws.port=8546 \
              --ws.origins="*" \
              --ws.api=debug,eth,txpool,net,engine \
              --syncmode=full \
              --gcmode=archive \
              --nodiscover \
              --maxpeers=0 \
              --networkid=$NETWORK_ID \
              --authrpc.vhosts="*" \
              --authrpc.addr=0.0.0.0 \
              --authrpc.port=8551 \
              --authrpc.jwtsecret=/jwtsecret \
              --metrics \
              --metrics.port=6060 \
              --metrics.addr=0.0.0.0 \
              --rollup.disabletxpoolgossip=true \
            EOF
          ]
          env {
            name = "NETWORK_ID"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "NETWORK_ID"
              }
            }
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
            name       = "op-geth"
            mount_path = "/data"
          }
          volume_mount {
            name       = "jwtsecret"
            mount_path = "/jwtsecret"
            sub_path   = "jwtsecret"
          }
        }
        container {
          name              = "op-node"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.9.4"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            apk add curl
            if [ ! -e "/rollup.json" ]; then
              echo "downloading rollup.json"
              curl $ROLLUP_URL > rollup.json
            else
              echo "rollup.json already exists"
            fi

            exec op-node \
              --l2=http://localhost:8551 \
              --l2.jwt-secret=/jwtsecret \
              --sequencer.enabled=true \
              --sequencer.l1-confs=5 \
              --verifier.l1-confs=4 \
              --rollup.config=./rollup.json \
              --rpc.addr=0.0.0.0 \
              --rpc.port=8547 \
              --rpc.enable-admin \
              --p2p.sequencer.key=$SEQUENCER_PRIVATE_KEY \
              --p2p.disable \
              --l1=http://geth-lighthouse.holesky-geth-lighthouse.svc:8545 \
              --l1.trustrpc \
              --l1.rpckind=debug_geth \
              --l1.beacon=http://geth-lighthouse.holesky-geth-lighthouse.svc:3500 \
              --metrics.enabled=true \
              --metrics.addr=0.0.0.0 \
              --metrics.port=6061
            EOF
          ]
          env {
            name = "ROLLUP_URL"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "ROLLUP_URL"
              }
            }
          }
          env {
            name = "SEQUENCER_PRIVATE_KEY"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "SEQUENCER_PRIVATE_KEY"
              }
            }
          }
          port {
            name           = "node-rpc"
            container_port = 8547
            protocol       = "TCP"
          }
          port {
            name           = "node-metrics"
            container_port = 6061
            protocol       = "TCP"
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

resource "kubernetes_service" "holesky_op_sequencer" {
  metadata {
    name      = "op-sequencer"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name               = "op-sequencer"
      "eth-network"      = "holesky"
      "eth-op-sequencer" = "true"
      "eth-op-node"      = "true"
      "eth-op-geth"      = "true"
    }
  }
  spec {
    // op-geth
    port {
      name        = "geth-http"
      port        = 8545
      target_port = "geth-http"
      protocol    = "TCP"
    }
    port {
      name        = "geth-ws"
      port        = 8546
      target_port = "geth-ws"
      protocol    = "TCP"
    }
    port {
      name        = "geth-authrpc"
      port        = 8551
      target_port = "geth-authrpc"
      protocol    = "TCP"
    }
    port {
      name        = "geth-metrics"
      port        = 6060
      target_port = "geth-metrics"
      protocol    = "TCP"
    }
    // op-node
    port {
      name        = "node-rpc"
      port        = 8547
      target_port = "node-rpc"
      protocol    = "TCP"
    }
    port {
      name        = "node-metrics"
      port        = 6061
      target_port = "node-metrics"
      protocol    = "TCP"
    }
    selector = {
      name               = "op-sequencer"
      "eth-network"      = "holesky"
      "eth-op-sequencer" = "true"
      "eth-op-node"      = "true"
      "eth-op-geth"      = "true"
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}
