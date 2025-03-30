resource "kubernetes_persistent_volume_claim" "erigon" {
  metadata {
    name      = local.erigon_pvc_name
    namespace = var.namespace
    labels = {
      name            = local.name
      "eth-execution" = "true"
      "eth-network"   = var.eth_network
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.erigon_pvc_size
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}
