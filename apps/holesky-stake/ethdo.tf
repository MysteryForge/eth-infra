# resource "kubernetes_secret" "vouch0" {
#   metadata {
#     name      = "vouch0"
#     namespace = kubernetes_namespace.holesky_stake.metadata.0.name
#   }

#   data = {
#     "vouch0.key" = file("${path.module}/config/certs/vouch0.key")
#     "vouch0.crt" = file("${path.module}/config/certs/vouch0.crt")
#   }
# }


# resource "kubernetes_stateful_set" "ethdo" {
#   metadata {
#     name      = "ethdo"
#     namespace = kubernetes_namespace.holesky_stake.metadata.0.name
#     labels = {
#       name = "ethdo"
#     }
#   }

#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         name = "ethdo"
#       }
#     }
#     service_name = "ethdo"
#     update_strategy {
#       type = "RollingUpdate"
#     }

#     template {
#       metadata {
#         labels = {
#           name = "ethdo"
#         }
#       }

#       spec {
#         termination_grace_period_seconds = 10
#         volume {
#           name = "dirk-authority"
#           secret {
#             secret_name = kubernetes_secret.dirk_authority.metadata.0.name
#           }
#         }

#         volume {
#           name = "vouch0"
#           secret {
#             secret_name = kubernetes_secret.vouch0.metadata.0.name
#           }
#         }

#         container {
#           name              = "ethdo"
#           image             = "wealdtech/ethdo:1.36.1"
#           image_pull_policy = "IfNotPresent"
#           command           = ["/bin/sh", "-c"]
#           args = [
#             <<EOF
#             set -xe
#             while true; do
#               echo "Hello, Kubernetes!";
#               sleep 30;
#             done
#             EOF
#           ]
#           volume_mount {
#             name       = "dirk-authority"
#             mount_path = "/config/certs/dirk_authority.crt"
#             sub_path   = "dirk_authority.crt"
#             read_only  = true
#           }

#           volume_mount {
#             name       = "vouch0"
#             mount_path = "/config/certs/vouch0.crt"
#             sub_path   = "vouch0.crt"
#             read_only  = true
#           }
#           volume_mount {
#             name       = "vouch0"
#             mount_path = "/config/certs/vouch0.key"
#             sub_path   = "vouch0.key"
#             read_only  = true
#           }
#         }
#       }
#     }
#   }
# }
