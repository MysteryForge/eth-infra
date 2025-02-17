resource "kubernetes_persistent_volume_claim" "holesky_geth_lighthouse_geth" {
  metadata {
    name      = "node-huq-geth"
    namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    labels = {
      name            = "node-huq"
      "eth-execution" = "true"
      "eth-network"   = "holesky"
      "eth-node-key"  = "node-huq"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "150Gi"
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}

resource "kubernetes_persistent_volume_claim" "holesky_geth_lighthouse_lighthouse" {
  metadata {
    name      = "node-huq-lighthouse"
    namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    labels = {
      name           = "node-huq"
      "eth-beacon"   = "true"
      "eth-network"  = "holesky"
      "eth-node-key" = "node-huq"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "150Gi"
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}
