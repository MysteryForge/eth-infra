
resource "helm_release" "grafana" {
  name       = "grafana-dashboard"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "8.6.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values = [
    yamlencode({
      assertNoLeakedSecrets = false
      "grafana.ini" = {
        server = {
          domain   = local.grafana_domain
          root_url = local.grafana_url
        }
        auth = {
          disable_login_form = true
        }
        "auth.basic" = {
          enabled = false
        }
        "auth.generic_oauth" = {
          enabled             = true
          name                = "dex"
          auto_login          = true
          allow_sign_up       = true
          client_id           = "grafana"
          client_secret       = var.oidc_grafana_secret
          scopes              = "openid profile email groups"
          auth_url            = format("%s/auth", local.auth_domain)
          token_url           = format("%s/token", local.auth_domain)
          api_url             = format("%s/userinfo", local.auth_domain)
          role_attribute_path = var.auth_roles_path
        }
      }
      sidecar = {
        datasources = {
          enabled         = true
          label           = "grafana_datasource"
          skipReload      = true
          initDatasources = true
        }
        dashboards = {
          enabled          = true
          label            = "grafana_dashboard"
          folderAnnotation = "dashboards"
          provider = {
            folderFromFilesStructure = true
          }
          searchNamespace = "ALL"
        }
        alerts = {
          enabled = true
          label   = "grafana_alert"
        }
      }
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hosts = [
          local.grafana_domain
        ]
        tls = [
          {
            hosts = [
              local.grafana_domain
            ]
            secretName = "grafana-tls"
          }
        ]
      }
      persistence = {
        enabled          = true
        storageClassName = "lvmpv-xfs"
        size             = "5Gi"
      }
      # only one instance running because of mounted volume
      deploymentStrategy = {
        type = "Recreate"
      }
      serviceMonitor = {
        enabled = true
      }
    })
  ]
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "grafana_datasource" = "1"
    }
  }

  data = {
    "datasources.yaml" = yamlencode({
      apiVersion = 1
      datasources = [
        {
          name   = "loki"
          type   = "loki"
          access = "proxy"
          url    = "http://loki.monitoring.svc.cluster.local:3100"
        },
        {
          name   = "victoria-metrics"
          type   = "prometheus"
          access = "proxy"
          url    = "http://vmselect-victoria-metrics-cluster.monitoring.svc:8481/select/0/prometheus"
        }
      ]
    })
  }
}


locals {
  grafana_dashboars = [
    "${path.module}/dashboards/node-exporter.json",
    "${path.module}/dashboards/apiserver.json",
    "${path.module}/dashboards/cluster-total.json",
    "${path.module}/dashboards/controller-manager.json",
    "${path.module}/dashboards/k8s-resources-cluster.json",
    "${path.module}/dashboards/k8s-resources-namespace.json",
    "${path.module}/dashboards/k8s-resources-node.json",
    "${path.module}/dashboards/k8s-resources-pod.json",
    "${path.module}/dashboards/k8s-resources-workload.json",
    "${path.module}/dashboards/k8s-resources-workloads-namespace.json",
    "${path.module}/dashboards/namespace-by-pod.json",
    "${path.module}/dashboards/namespace-by-workload.json",
    "${path.module}/dashboards/kubelet.json",
    "${path.module}/dashboards/persistentvolumesusage.json",
    "${path.module}/dashboards/pod-total.json",
    "${path.module}/dashboards/proxy.json",
    "${path.module}/dashboards/scheduler.json",
    "${path.module}/dashboards/workload-total.json",
    "${path.module}/dashboards/nginx-ingress-controller.json", //https://grafana.com/grafana/dashboards/21336-nginx-ingress-controller/
  ]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = toset(local.grafana_dashboars)
  metadata {
    name      = "grafana-dashboards-${random_string.grafana_dashboard_suffix[each.key].result}"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "grafana_dashboard" = "1"
    }
    annotations = {
      "dashboards" = "k8s"
    }
  }
  data = {
    "${random_string.grafana_dashboard_suffix[each.key].result}.json" = file("${each.key}")
  }
}

resource "random_string" "grafana_dashboard_suffix" {
  for_each = toset(local.grafana_dashboars)
  length   = 4
  special  = false
  upper    = false
}

resource "kubernetes_secret" "grafana_alerts" {
  metadata {
    name      = "grafana-alerts"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      "grafana_alert" = "1"
    }
  }
  data = {
    "contactpoints.yaml" = yamlencode({
      apiVersion = 1
      contactPoints = [
        {
          name  = "discord"
          orgId = 1
          receivers = [
            {
              name                  = "discord"
              type                  = "discord"
              uid                   = "discord"
              isDefault             = true
              sendReminder          = true
              frequency             = "15m"
              disableResolveMessage = false
              settings = {
                url                  = var.discord_webhook_url
                use_discord_username = false
              }
            }
          ]
        }
      ]
    })
    "policies.yaml" = yamlencode({
      apiVersion = 1
      policies = [
        {
          orgId    = 1
          receiver = "discord"
          group_by = [
            "alertname",
            "grafana_folder"
          ]
        }
      ]
    })
  }
}
