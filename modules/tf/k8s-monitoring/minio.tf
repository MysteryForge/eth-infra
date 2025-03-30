resource "helm_release" "minio" {
  name       = "minio"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "14.7.16"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values = [
    yamlencode({
      mode = "standalone"
      auth = {
        # we should not worry about the auth here because minio should not be exposed
        rootUser     = "admin"
        rootPassword = "superrootsecret"
      }
      persistance = {
        size         = "5Gi"
        storageClass = "lvmpv-xfs"
      }
      provisioning = {
        enabled = true
        users = [
          {
            username = "loki"
            password = "supersecret"
            policies = ["readwrite"]
          }
        ]
        buckets = [
          {
            name = "loki-data"
          }
        ]
      }
      image = {
        debug = true
      }
      extraEnvVars = [
        {
          name  = "MINIO_BROWSER_LOGIN_ANIMATION"
          value = "off"
        }
      ]
    })
  ]
}
