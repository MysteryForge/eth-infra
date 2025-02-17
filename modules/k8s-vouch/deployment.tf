resource "kubernetes_deployment" "vouch" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name = local.name
    }
    annotations = {
      "reloader.stakater.com/auto" = "true"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = local.name
      }
    }
    template {
      metadata {
        labels = {
          name = local.name
        }
      }
      spec {
        volume {
          name = "vouch-config"
          secret {
            secret_name = kubernetes_secret.vouch_config.metadata.0.name
          }
        }
        volume {
          name = "dirk-authority"
          secret {
            secret_name = var.dirk_authority
          }
        }
        volume {
          name = "vouch-certs"
          secret {
            secret_name = kubernetes_secret.vouch_certs.metadata.0.name
          }
        }
        volume {
          name = "blockrelay"
          secret {
            secret_name = kubernetes_secret.blockrelay.metadata.0.name
          }
        }
        container {
          name              = "vouch"
          image             = "attestant/vouch:1.9.2"
          image_pull_policy = "IfNotPresent"
          args              = ["--base-dir=/config"]
          port {
            name           = "metrics"
            container_port = 8081
            protocol       = "TCP"
          }
          volume_mount {
            name       = "vouch-config"
            mount_path = "/config/vouch.yml"
            sub_path   = "vouch.yml"
            read_only  = true
          }
          volume_mount {
            name       = "dirk-authority"
            mount_path = "/config/certs/dirk_authority.crt"
            sub_path   = "dirk_authority.crt"
            read_only  = true
          }
          volume_mount {
            name       = "vouch-certs"
            mount_path = "/config/certs/vouch.crt"
            sub_path   = "vouch.crt"
            read_only  = true
          }
          volume_mount {
            name       = "vouch-certs"
            mount_path = "/config/certs/vouch.key"
            sub_path   = "vouch.key"
            read_only  = true
          }
          volume_mount {
            name       = "blockrelay"
            mount_path = "/config/blockrelay.json"
            sub_path   = "blockrelay.json"
            read_only  = true
          }
        }
      }
    }
  }
}
