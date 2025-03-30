resource "kubernetes_persistent_volume_claim" "geth" {
  metadata {
    name      = local.geth_pvc_name
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
        storage = var.geth_pvc_size
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}

resource "kubernetes_persistent_volume_claim" "prysm" {
  metadata {
    name      = local.prysm_pvc_name
    namespace = var.namespace
    labels = {
      name          = local.name
      "eth-beacon"  = "true"
      "eth-network" = var.eth_network
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.prysm_pvc_size
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}
