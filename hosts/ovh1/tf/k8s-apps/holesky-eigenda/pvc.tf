resource "kubernetes_persistent_volume_claim" "holesky_eigenda" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      name = "operator"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "30Gi"
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}

