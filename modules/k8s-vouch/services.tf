resource "kubernetes_service" "dirk" {
  metadata {
    name      = local.svc_name
    namespace = var.namespace
    labels = {
      name = local.svc_name
    }
  }
  spec {
    port {
      name        = "metrics"
      port        = 8081
      target_port = "metrics"
      protocol    = "TCP"
    }
    selector = {
      name = local.name
    }
    session_affinity = "None"
    type             = "ClusterIP"
  }
}