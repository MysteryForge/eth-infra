resource "kubernetes_persistent_volume_claim" "dirk" {
  metadata {
    name      = local.pvc_name
    namespace = var.namespace
    labels = {
      name = local.pvc_name
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "312Mi"
      }
    }
    storage_class_name = "lvmpv-xfs"
  }
}
