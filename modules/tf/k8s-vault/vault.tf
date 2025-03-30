# resource "helm_release" "vault" {
#   name       = "vault"
#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "vault"
#   version    = "0.28.1"
#   namespace  = kubernetes_namespace.external_secrets.metadata[0].name

#   values = [yamlencode({
#     server = {
#       dataStorage = {
#         enabled      = true
#         storageClass = "lvmpv-xfs"
#         size         = "5Gi"
#       }
#       ha = {
#         enabled  = true
#         replicas = 1
#         raft = {
#           enabled   = true
#           setNodeId = true
#         }
#       }
#     }
#   })]
# }
