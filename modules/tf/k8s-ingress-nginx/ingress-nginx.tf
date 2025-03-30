resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  values = [yamlencode({
    controller = {
      config = {
        "global-rate-limit-memcached-host" = "memcached.${kubernetes_namespace.ingress_nginx.metadata[0].name}.svc.cluster.local"
        "global-rate-limit-memcached-port" = "11211"
        "limit-req-status-code"            = 429
      }
      metrics = {
        port    = 10254
        enabled = true
        serviceMonitor = {
          enabled = true
        }
      }
      hostPort = {
        enabled = true
      }
      kind         = "DaemonSet"
      nodeSelector = {}
      service = {
        external = {
          enabled = false
        }
      }
    }
  })]
}
