resource "kubernetes_config_map" "holesky_eigenda_nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
  }

  data = {
    "nginx.conf" = <<EOF
    events {}
    http {
      limit_req_zone $binary_remote_addr zone=ip:10m rate=10r/s;

      server {
        listen 32004;
        client_max_body_size 1M;
        http2 on;
        location / {
          limit_req zone=ip burst=50 nodelay;
          limit_req_status 429;
          grpc_set_header X-Real-IP $remote_addr;
          grpc_pass grpc://operator:32004;
        }
      }

      server {
        listen 32005;
        client_max_body_size 100M;
        http2 on;
        location / {
          allow 54.144.24.178;
          allow 34.232.117.230;
          allow 18.214.113.214;

          # my current ip
          # allow <IP>;

          # deny other IPs
          deny all;

          grpc_set_header X-Real-IP $remote_addr;
          grpc_pass grpc://operator:32005;
        }
      }
    }
    EOF
  }
}

resource "kubernetes_deployment" "holesky_eigenda_nginx" {
  depends_on = [kubernetes_stateful_set.holesky_eigenda, kubernetes_service.holesky_eigenda_operator]
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      name = "nginx"
    }
    annotations = {
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          name = "nginx"
        }
      }
      spec {
        volume {
          name = "nginx"
          config_map {
            name = kubernetes_config_map.holesky_eigenda_nginx.metadata.0.name
          }
        }
        container {
          name    = "nginx"
          image   = "nginx:1.27"
          command = ["/bin/sh", "-c"]
          args = [
            <<EOF
            set -ex
            nginx -g 'daemon off;'
            EOF
          ]
          port {
            name           = "grpcr"
            container_port = 32004
            protocol       = "TCP"
          }
          port {
            name           = "grpcd"
            container_port = 32005
            protocol       = "TCP"
          }
          volume_mount {
            name       = "nginx"
            mount_path = "/etc/nginx"
            read_only  = true
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "holesky_eigenda_nginx" {
  metadata {
    name      = "grpc"
    namespace = kubernetes_namespace.holesky_eigenda.metadata[0].name
    labels = {
      name = "grpc"
    }
  }
  spec {
    port {
      name        = "grpcr"
      port        = 32004
      target_port = "grpcr"
      node_port   = 32004
    }
    port {
      name        = "grpcd"
      port        = 32005
      target_port = "grpcd"
      node_port   = 32005
    }

    selector = {
      name = "nginx"
    }
    external_traffic_policy = "Local"
    type                    = "NodePort"
  }
}
