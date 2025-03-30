
resource "kubernetes_ingress_v1" "geth_prysm" {
  metadata {
    name      = local.name
    namespace = var.namespace
    labels = {
      name                 = local.name
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "prysm"
      "eth-network"        = var.eth_network
    }
    annotations = {
      "cert-manager.io/cluster-issuer"                      = "letsencrypt-prod"
      "external-dns.alpha.kubernetes.io/ttl"                = "1m"
      "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "false"
      "nginx.ingress.kubernetes.io/upstream-hash-by"        = "$remote_addr"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"      = "3600"
      "nginx.ingress.kubernetes.io/proxy-body-size"         = "5m"
      "nginx.ingress.kubernetes.io/rewrite-target"          = "/$1"
      "nginx.ingress.kubernetes.io/auth-realm"              = "auth required"
      "nginx.ingress.kubernetes.io/auth-secret"             = var.basic_auth_secret_name
      "nginx.ingress.kubernetes.io/auth-type"               = "basic"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"      = "600"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.host
      http {
        path {
          path = "/cl/${var.name}/(.*)"
          backend {
            service {
              name = local.name
              port {
                name = "beacon-http"
              }
            }
          }
          path_type = "ImplementationSpecific"
        }
        path {
          path = "/el/${var.name}/(.*)"
          backend {
            service {
              name = local.name
              port {
                name = "geth-http"
              }
            }
          }
          path_type = "ImplementationSpecific"
        }

      }
    }
    tls {
      hosts       = [var.host]
      secret_name = "node-${var.name}-tls"
    }
  }
}

