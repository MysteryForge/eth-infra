resource "kubernetes_deployment" "memcached" {
  metadata {
    name      = "memcached"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = {
      app = "memcached"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "memcached"
      }
    }
    template {
      metadata {
        labels = {
          app = "memcached"
        }
      }
      spec {
        container {
          name  = "memcached"
          image = "memcached:1.6-alpine"

          port {
            name           = "memcached"
            container_port = 11211
          }
          resources {
            requests = {
              memory = "512Mi"
              cpu    = "512m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "memcached" {
  metadata {
    name      = "memcached"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
  spec {
    port {
      protocol    = "TCP"
      port        = 11211
      name        = "memcached"
      target_port = "memcached"
    }
    selector = {
      app = "memcached"
    }
  }
}

