resource "kubernetes_config_map" "holesky_op_proxyd" {
  metadata {
    name      = "op-proxyd"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name            = "op-proxyd"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
  }

  data = {
    "config.toml" = <<EOF
      ws_method_whitelist = [
        "eth_subscribe",
        "eth_call",
        "eth_chainId"
      ]
      ws_backend_group = "sequencer"

      [server]
      rpc_host = "0.0.0.0"
      rpc_port = 8080
      ws_host = "0.0.0.0"
      ws_port = 8085
      max_body_size_bytes = 10485760
      max_concurrent_rpcs = 1000
      log_level = "info"
      allow_all_origins = true

      [redis]
      url = "redis://op-proxyd-redis:6379"

      [cache]
      enabled = true
      ttl = "1h"

      [metrics]
      enabled = true
      host = "0.0.0.0"
      port = 6060

      [backend]
      response_timeout_seconds = 5
      max_response_size_bytes = 5242880
      max_retries = 3
      out_of_service_seconds = 600

      [backends]
      [backends.sequencer]
      rpc_url = "http://op-sequencer:8545"
      ws_url = "ws://op-sequencer:8546"
      max_rps = 3
      max_ws_conns = 1
      consensus_receipts_target = "eth_getBlockReceipts"

      [backend_groups]
      [backend_groups.sequencer]
      backends = ["sequencer"]
      consensus_max_block_range = 20000

      # Mapping of methods to backend groups.
      [rpc_method_mappings]
      eth_call = "sequencer"
      eth_chainId = "sequencer"
      eth_blockNumber = "sequencer"
      eth_estimateGas = "sequencer"
      eth_gasPrice = "sequencer"
      eth_getBalance = "sequencer"
      eth_getBlockByHash = "sequencer"
      eth_getBlockByNumber = "sequencer"
      eth_getBlockTransactionCountByHash = "sequencer"
      eth_getBlockTransactionCountByNumber = "sequencer"
      eth_getCode = "sequencer"
      eth_getStorageAt = "sequencer"
      eth_getTransactionByBlockHashAndIndex = "sequencer"
      eth_getTransactionByBlockNumberAndIndex = "sequencer"
      eth_getTransactionByHash = "sequencer"
      eth_getTransactionCount = "sequencer"
      eth_getTransactionReceipt = "sequencer"
      eth_getUncleByBlockHashAndIndex = "sequencer"
      eth_getUncleByBlockNumberAndIndex = "sequencer"
      eth_getUncleCountByBlockHash = "sequencer"
      eth_getUncleCountByBlockNumber = "sequencer"
      eth_sign = "sequencer"
      eth_signTypedData = "sequencer"
      eth_getLogs = "sequencer"
      net_version = "sequencer"
      eth_protocolVersion = "sequencer"
      eth_syncing = "sequencer"
      net_listening = "sequencer"
      net_peerCount = "sequencer"
      eth_mining = "sequencer"
      eth_hashrate = "sequencer"
      eth_feeHistory = "sequencer"
      eth_maxPriorityFeePerGas = "sequencer"
      eth_newBlockFilter = "sequencer"
      eth_sendRawTransaction = "sequencer"
    EOF
  }
}

resource "kubernetes_deployment" "holesky_op_proxyd_redis" {
  metadata {
    name      = "op-proxyd-redis"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                             = "op-proxyd-redis"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "op-proxyd-redis"
      }
    }
    template {
      metadata {
        labels = {
          name                             = "op-proxyd-redis"
          "eth-network"   = "holesky"
          "eth-op-proxyd" = "true"
        }
      }
      spec {
        container {
          name              = "op-proxyd-redis"
          image             = "redis:7.4"
          image_pull_policy = "IfNotPresent"
          command           = ["redis-server"]
          port {
            name           = "redis"
            container_port = 6379
            protocol       = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "holesky_op_proxy_redis" {
  metadata {
    name      = "op-proxyd-redis"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                             = "op-proxyd-redis"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
  }

  spec {
    port {
      name        = "op-proxyd-redis"
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
    selector = {
      name = "op-proxyd-redis"
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}

resource "kubernetes_deployment" "holesky_op_proxyd" {
  metadata {
    name      = "op-proxyd"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                             = "op-proxyd"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
    annotations = {
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "op-proxyd"
      }
    }
    template {
      metadata {
        labels = {
          name                             = "op-proxyd"
          "eth-network"   = "holesky"
          "eth-op-proxyd" = "true"
        }
      }
      spec {
        volume {
          name = "op-proxyd"
          config_map {
            name = kubernetes_config_map.holesky_op_proxyd.metadata[0].name
          }
        }
        container {
          name              = "op-proxyd"
          image             = "us-docker.pkg.dev/oplabs-tools-artifacts/images/proxyd:v4.8.6"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -x -e
            exec proxyd /proxyd/config.toml
            EOF
          ]
          volume_mount {
            name       = "op-proxyd"
            mount_path = "/proxyd"
            read_only  = true
          }
          port {
            name           = "rpc"
            container_port = 8080
            protocol       = "TCP"
          }
          port {
            name           = "ws"
            container_port = 8085
            protocol       = "TCP"
          }
          port {
            name           = "metrics"
            container_port = 6060
            protocol       = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "holesky_op_proxyd" {
  metadata {
    name      = "op-proxyd"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name                             = "op-proxyd"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
  }

  spec {
    port {
      name        = "rpc"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
    port {
      name        = "ws"
      port        = 8085
      target_port = 8085
      protocol    = "TCP"
    }
    port {
      name        = "metrics"
      port        = 6060
      target_port = 6060
      protocol    = "TCP"
    }
    selector = {
      name = "op-proxyd"
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}