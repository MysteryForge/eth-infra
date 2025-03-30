resource "helm_release" "loki" {
  depends_on = [helm_release.minio]
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "2.16.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values = [
    yamlencode({
      image = {
        tag = "2.9.3"
      }
      config = {
        auth_enabled = false

        limits_config = {
          reject_old_samples           = false
          retention_period             = "72h" # 3 days
          max_concurrent_tail_requests = 5
          max_query_parallelism        = 10
        }

        schema_config = {
          configs = [{
            from         = "2021-01-01"
            store        = "boltdb-shipper"
            object_store = "s3"
            schema       = "v11"
            index = {
              prefix = "index_"
              period = "24h"
            }
          }]
        }
        storage_config = {
          aws = {
            # The period behind the domain forces the S3 library to use it as a host name, not as an AWS region.
            # This also creates an index folder in minio which is then used for indexing the logs
            s3               = "s3://loki:supersecret@minio.monitoring.svc.cluster.local.:9000/loki-data"
            s3forcepathstyle = true
          }
          boltdb_shipper = {
            shared_store = "s3"
          }
        }
        compactor = {
          shared_store      = "s3"
          retention_enabled = true
        }
        limits_config = {
          volume_enabled = true
        }
      }
      replicas = 1
      serviceMonitor = {
        enabled = true
      }
    })
  ]
}

