resource "kubernetes_ingress_v1" "holesky_op_proxyd" {
  metadata {
    name      = "op-proxyd"
    namespace = kubernetes_namespace.holesky_op.metadata[0].name
    labels = {
      name            = "op-proxyd"
      "eth-network"   = "holesky"
      "eth-op-proxyd" = "true"
    }
    annotations = {
      "cert-manager.io/cluster-issuer"                       = "letsencrypt-prod"
      "external-dns.alpha.kubernetes.io/ttl"                 = "1m"
      "external-dns.alpha.kubernetes.io/cloudflare-proxied"  = "false"
      "nginx.ingress.kubernetes.io/upstream-hash-by"         = "$remote_addr"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"       = "3600"
      "nginx.ingress.kubernetes.io/proxy-body-size"          = "5m"
      "nginx.ingress.kubernetes.io/rewrite-target"           = "/$1"
      "nginx.ingress.kubernetes.io/global-rate-limit"        = "120"
      "nginx.ingress.kubernetes.io/global-rate-limit-window" = "1m"
      "nginx.ingress.kubernetes.io/global-rate-limit-key"    = "$remote_addr"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "holesky-op.${var.domain}"
      http {
        path {
          path = "/v1(.*)"
          backend {
            service {
              name = kubernetes_service.holesky_op_proxyd.metadata[0].name
              port {
                name = kubernetes_service.holesky_op_proxyd.spec[0].port[0].name
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = ["holesky-op.${var.domain}"]
      secret_name = "holesky-op-proxyd-tls"
    }
  }
}