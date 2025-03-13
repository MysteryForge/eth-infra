resource "kubernetes_stateful_set" "holesky_eigenda" {
  timeouts {
    create = "20m"
    update = "10m"
    delete = "10m"
  }

  metadata {
    name      = "operator"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      name = "operator"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "operator"
      }
    }
    service_name = "operator"
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name = "operator"
        }
      }
      spec {
        termination_grace_period_seconds = 60
        volume {
          name = "operator"
          persistent_volume_claim {
            claim_name = "operator"
          }
        }

        volume {
          name = "bls"
          secret {
            secret_name = "eigenda-bls"
          }
        }

        init_container {
          name              = "setup-init"
          image             = "alpine:3.20"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -ex
            apk add curl
            apk add tar

            if [ ! -f "/app/operator/srs_setup.sh" ]; then
              curl -L https://github.com/Layr-Labs/eigenda-operator-setup/archive/refs/tags/v0.8.5.tar.gz > eigenda-operator.tar.gz
              mkdir -p /app/operator
              tar -xzvf eigenda-operator.tar.gz --strip-components=1 -C /app/operator
            else
              echo "eigenda /app/operator directory already exists"
            fi

            cd /app/operator && ./srs_setup.sh

            if [ ! -f "/app/logs/opr.log" ]; then
              mkdir -p /app/logs
              touch /app/logs/opr.log
            else
              echo "opr.log already exists"
            fi
            EOF
          ]
          volume_mount {
            name              = "operator"
            mount_path        = "/app"
            mount_propagation = "None"
          }
        }

        container {
          name              = "operator"
          image             = "ghcr.io/layr-labs/eigenda/opr-node:0.8.5"
          image_pull_policy = "IfNotPresent"
          // mostly already preselect envs from the operator
          env {
            name  = "MAIN_SERVICE_NAME"
            value = "eigenda-native-node"
          }
          env {
            name  = "NODE_HOST"
            value = "eigenda-native-node"
          }
          env {
            name  = "NETWORK_NAME"
            value = "eigenda-network"
          }
          env {
            name  = "NODE_PRIVATE_KEY"
            value = ""
          }
          # EigenDA specific configs
          env {
            name  = "NODE_EXPIRATION_POLL_INTERVAL"
            value = "180"
          }
          env {
            name  = "NODE_CACHE_ENCODED_BLOBS"
            value = "true"
          }
          env {
            name  = "NODE_NUM_WORKERS"
            value = "1"
          }
          env {
            name  = "NODE_DISPERSAL_PORT"
            value = "32005"
          }
          env {
            name  = "NODE_QUORUM_ID_LIST"
            value = "0"
          }
          env {
            name  = "NODE_VERBOSE"
            value = "true"
          }
          // external port
          env {
            name  = "NODE_RETRIEVAL_PORT"
            value = "32004"
          }
          env {
            name  = "NODE_TIMEOUT"
            value = "20s"
          }
          env {
            name  = "NODE_SRS_ORDER"
            value = "268435456"
          }
          env {
            name  = "NODE_SRS_LOAD"
            value = "8388608"
          }
          env {
            name  = "NODE_INTERNAL_DISPERSAL_PORT"
            value = "32005"
          }
          env {
            name  = "NODE_INTERNAL_RETRIEVAL_PORT"
            value = "32004"
          }
          env {
            name  = "NODE_REACHABILITY_POLL_INTERVAL"
            value = "60"
          }
          env {
            name  = "NODE_DATAAPI_URL"
            value = "https://dataapi-holesky.eigenda.xyz"
          }
          env {
            name  = "NODE_BLS_KEY_FILE"
            value = "/app/operator-keys/bls"
          }
          env {
            name  = "NODE_G1_PATH"
            value = "/app/operator/resources/g1.point"
          }
          env {
            name  = "NODE_G2_POWER_OF_2_PATH"
            value = "/app/operator/resources/g2.point.powerOf2"
          }
          env {
            name  = "NODE_CACHE_PATH"
            value = "/app/cache"
          }
          env {
            name  = "NODE_LOG_PATH"
            value = "/app/logs/opr.log"
          }
          env {
            name  = "NODE_DB_PATH"
            value = "/app/data"
          }
          env {
            name  = "NODE_LOG_LEVEL"
            value = "debug"
          }
          env {
            name  = "NODE_LOG_FORMAT"
            value = "text"
          }
          env {
            name  = "NODE_ENABLE_METRICS"
            value = "true"
          }
          env {
            name  = "NODE_METRICS_PORT"
            value = "9092"
          }
          env {
            name  = "NODE_ENABLE_NODE_API"
            value = "true"
          }
          env {
            name  = "NODE_API_PORT"
            value = "9091"
          }
          # holesky smart contracts
          env {
            name  = "NODE_EIGENDA_SERVICE_MANAGER"
            value = "0xD4A7E1Bd8015057293f0D0A557088c286942e84b"
          }
          env {
            name  = "NODE_BLS_OPERATOR_STATE_RETRIVER"
            value = "0xB4baAfee917fb4449f5ec64804217bccE9f46C67"
          }
          env {
            name  = "NODE_CHURNER_URL"
            value = "churner-holesky.eigenda.xyz:443"
          }
          env {
            name  = "NODE_CLIENT_IP_HEADER"
            value = "x-real-ip"
          }
          env {
            name  = "NODE_PUBLIC_IP_CHECK_INTERVAL"
            value = "0"
          }

          // todo replace
          env {
            name = "NODE_HOSTNAME"
            value_from {
              secret_key_ref {
                name = "eigenda"
                key  = "NODE_HOSTNAME"
              }
            }
          }
          env {
            name  = "NODE_CHAIN_RPC"
            value = "http://geth-lighthouse.holesky-geth-lighthouse.svc:8545"
          }
          env {
            name  = "NODE_CHAIN_ID"
            value = "17000"
          }
          env {
            name  = "NODE_PUBLIC_IP_PROVIDER"
            value = "seeip"
          }
          env {
            name  = "NODE_ECDSA_KEY_PASSWORD"
            value = ""
          }
          env {
            name  = "NODE_BLS_KEY_PASSWORD"
            value = ""
          }

          port {
            name           = "retrieval"
            container_port = 32004
          }
          port {
            name           = "dispersal"
            container_port = 32005
          }
          port {
            name           = "api"
            container_port = 9091
          }
          port {
            name           = "metrics"
            container_port = 9092
          }

          volume_mount {
            name              = "operator"
            mount_path        = "/app"
            mount_propagation = "None"
          }
          volume_mount {
            name              = "ecdsa"
            mount_path        = "/app/operator-keys/ecdsa"
            sub_path          = "ecdsa"
            mount_propagation = "None"
          }
          volume_mount {
            name              = "bls"
            mount_path        = "/app/operator-keys/bls"
            sub_path          = "bls"
            mount_propagation = "None"
          }
        }
      }
    }
  }
}
