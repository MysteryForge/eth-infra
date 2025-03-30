resource "helm_release" "openebs" {
  name       = "openebs"
  repository = "https://openebs.github.io/openebs"
  chart      = "openebs"
  version    = "4.2.0"
  namespace  = kubernetes_namespace.openebs.metadata[0].name
  wait       = true
  values = [yamlencode({
    engines = {
      local = {
        zfs = {
          enabled = false
        }
      }
      replicated = {
        mayastor = {
          enabled = false
        }
      }
    }
    "openebs-crds" = {
      csi = {
        volumeSnapshots = {
          enabled = false
          keep    = false
        }
      }
    }
    "zfs-localpv" = {
      crds = {
        zfsLocalPv = {
          enabled = false
        }
      }

    }
  })]
}

