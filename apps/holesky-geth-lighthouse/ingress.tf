
resource "kubernetes_ingress_v1" "holesky_geth_lighthouse" {
  metadata {
    name      = "geth-lighthouse"
    namespace = kubernetes_namespace.holesky_geth_lighthouse.metadata[0].name
    labels = {
      name                                  = "geth-lighthouse"
      "eth-execution"      = "true"
      "eth-beacon"         = "true"
      "eth-execution-type" = "geth"
      "eth-beacon-type"    = "lighthouse"
      "eth-network"        = "holesky"
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
      "nginx.ingress.kubernetes.io/auth-secret"             = "ingress-basic-auth"
      "nginx.ingress.kubernetes.io/auth-type"               = "basic"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"      = "600"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "holesky-node.${var.domain}"
      http {
        path {
          path = "/cl/huq/(.*)"
          backend {
            service {
              name = kubernetes_service.holesky_geth_lighthouse.metadata.0.name
              port {
                name = kubernetes_service.holesky_geth_lighthouse.spec.0.port.4.name
              }
            }
          }
          path_type = "ImplementationSpecific"
        }
        path {
          path = "/ex/huq/(.*)"
          backend {
            service {
              name = kubernetes_service.holesky_geth_lighthouse.metadata[0].name
              port {
                name = kubernetes_service.holesky_geth_lighthouse.spec[0].port[0].name
              }
            }
          }
          path_type = "ImplementationSpecific"
        }

      }
    }
    tls {
      hosts       = ["holesky-node.${var.domain}"]
      secret_name = "holesky-node-lighthouse-tls"
    }
  }
}

