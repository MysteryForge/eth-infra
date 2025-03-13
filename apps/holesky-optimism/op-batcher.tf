resource "kubernetes_stateful_set" "holesky_op_batcher" {
  metadata {
    name      = "op-batcher"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                              = "op-batcher"
      "eth-network"    = "holesky"
      "eth-op-batcher" = "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "op-batcher"
      }
    }
    service_name = "op-batcher"
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name                              = "op-batcher"
          "eth-network"    = "holesky"
          "eth-op-batcher" = "true"
        }
      }
      spec {
        termination_grace_period_seconds = 60
        container {
          name              = "op-batcher"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-batcher:v1.9.3"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            exec op-batcher \
              --l1-eth-rpc=http://geth-lighthouse.holesky-geth-lighthouse.svc:8545 \
              --l2-eth-rpc=http://op-sequencer.holesky-optimism.svc:8545 \
              --rollup-rpc=http://op-sequencer.holesky-optimism.svc:8547 \
              --poll-interval=1s \
              --sub-safety-margin=6 \
              --resubmission-timeout=30s \
              --rpc.addr=0.0.0.0 \
              --rpc.port=8548 \
              --rpc.enable-admin \
              --max-channel-duration=25 \
              --private-key=$BATCHER_PRIVATE_KEY \
              --data-availability-type=blobs \
              --wait-node-sync \
              --metrics.enabled \
              --metrics.addr=0.0.0.0 \
              --metrics.port=6060
              EOF
          ]
          env {
            name = "BATCHER_PRIVATE_KEY"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "BATCHER_PRIVATE_KEY"
              }
            }
          }
        }
      }
    }
  }
}
