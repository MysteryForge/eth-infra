resource "kubernetes_stateful_set" "dirk0" {
  metadata {
    name      = local.sts_name
    namespace = var.namespace
    labels = {
      name = local.sts_name
    }
    annotations = {
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = local.sts_name
      }
    }
    service_name = local.sts_name
    update_strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name = local.sts_name
        }
      }

      spec {
        termination_grace_period_seconds = 60
        volume {
          name = "dirk-pvc"
          persistent_volume_claim {
            claim_name = local.pvc_name // we cant use kubernetes persistent volume claim here because it is then waiting for pvc to be created and it cannot be until one of the pods claims it
          }
        }
        volume {
          name = "dirk-config"
          secret {
            secret_name = kubernetes_secret.dirk_config.metadata.0.name
          }
        }
        volume {
          name = "dirk-authority"
          secret {
            secret_name = var.dirk_authority
          }
        }
        volume {
          name = "dirk-certs"
          secret {
            secret_name = kubernetes_secret.dirk_certs.metadata.0.name
          }
        }
        volume {
          name = "wallet-passphrase"
          secret {
            secret_name = var.wallet_passphrase
          }
        }
        volume {
          name = "account-passphrase"
          secret {
            secret_name = var.account_passphrase
          }
        }

        init_container {
          name              = "dirk-init"
          image             = "wealdtech/ethdo:1.36.1"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -xe
            if [ ! -d "/data/wallets" ]; then
              ls -la
              ./ethdo --base-dir=/data/wallets wallet create --type=${var.wallet_type} --wallet=${var.wallet_name}
              echo "wallet ${var.wallet_name} created"
            else
              echo "wallet ${var.wallet_name} already exists"
              ./ethdo wallet list --base-dir=/data/wallets
              ./ethdo wallet info --base-dir=/data/wallets --wallet=${var.wallet_name}
            fi
            EOF
          ]
          volume_mount {
            name              = "dirk-pvc"
            mount_path        = "/data"
            mount_propagation = "None"
          }
        }

        container {
          name              = "dirk"
          image             = "attestant/dirk:1.2.0"
          image_pull_policy = "IfNotPresent"
          args              = ["--base-dir=/config"]
          port {
            name           = "grpc"
            container_port = 13141
            protocol       = "TCP"
          }
          port {
            name           = "metrics"
            container_port = 8081
            protocol       = "TCP"
          }
          volume_mount {
            name              = "dirk-pvc"
            mount_path        = "/data"
            mount_propagation = "None"
          }
          volume_mount {
            name       = "dirk-config"
            mount_path = "/config/dirk.yml"
            sub_path   = "dirk.yml"
            read_only  = true
          }
          volume_mount {
            name       = "dirk-authority"
            mount_path = "/config/certs/dirk_authority.crt"
            sub_path   = "dirk_authority.crt"
            read_only  = true
          }
          volume_mount {
            name       = "dirk-certs"
            mount_path = "/config/certs/dirk.crt"
            sub_path   = "dirk.crt"
            read_only  = true
          }
          volume_mount {
            name       = "dirk-certs"
            mount_path = "/config/certs/dirk.key"
            sub_path   = "dirk.key"
            read_only  = true
          }
          volume_mount {
            name       = "wallet-passphrase"
            mount_path = "/config/passphrases/wallet-passphrase.txt"
            sub_path   = "wallet-passphrase.txt"
            read_only  = true
          }
          volume_mount {
            name       = "account-passphrase"
            mount_path = "/config/passphrases/account-passphrase.txt"
            sub_path   = "account-passphrase.txt"
            read_only  = true
          }
        }
      }
    }
  }
}


