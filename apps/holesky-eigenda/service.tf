resource "kubernetes_service" "holesky_eigenda_operator" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      name = "operator"
    }
  }
  spec {
    selector = {
      name = "operator"
    }
    session_affinity = "None"
    type             = "ClusterIP"
    port {
      name        = "retrieval"
      port        = 32004
      target_port = 32004
    }
    port {
      name        = "dispersal"
      port        = 32005
      target_port = 32005
    }
    port {
      name        = "api"
      port        = 9091
      target_port = 9091
    }
    port {
      name        = "metrics"
      port        = 9092
      target_port = 9092
    }
  }
}
