resource "kubernetes_storage_class" "lvm_localpv_xfs" {
  # depends_on = [module.openebs_crd]
  metadata {
    name = "lvmpv-xfs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  allow_volume_expansion = true
  storage_provisioner    = "local.csi.openebs.io"
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    storage  = "lvm"
    volgroup = "pool"
    fsType   = "xfs"
  }
}
