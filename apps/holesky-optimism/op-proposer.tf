resource "kubernetes_stateful_set" "holesky_op_proposer" {
  metadata {
    name      = "op-proposer"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name              = "op-proposer"
      "eth-network"     = "holesky"
      "eth-op-proposer" = "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "op-proposer"
      }
    }
    service_name = "op-proposer"
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name              = "op-proposer"
          "eth-network"     = "holesky"
          "eth-op-proposer" = "true"
        }
      }
      spec {
        termination_grace_period_seconds = 60
        container {
          name              = "op-proposer"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/op-proposer:v1.9.3"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            exec op-proposer \
              --l1-eth-rpc=http://geth-lighthouse.holesky-geth-lighthouse.svc:8545 \
              --rollup-rpc=http://op-sequencer.holesky-optimism.svc:8547 \
              --poll-interval=12s \
              --rpc.addr=0.0.0.0 \
              --rpc.port=8560 \
              --wait-node-sync=true \
              --private-key=$PROPOSER_PRIVATE_KEY \
              --l2oo-address=$L2_OUTPUT_ORACLE_PROXY \
              --metrics.enabled \
              --metrics.addr=0.0.0.0 \
              --metrics.port=6060
              EOF
          ]
          env {
            name = "PROPOSER_PRIVATE_KEY"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "PROPOSER_PRIVATE_KEY"
              }
            }
          }
          env {
            name = "L2_OUTPUT_ORACLE_PROXY"
            value_from {
              secret_key_ref {
                name = "op-secrets"
                key  = "L2_OUTPUT_ORACLE_PROXY"
              }
            }
          }
        }
      }
    }
  }
}
