

resource "helm_release" "victoria_metrics_operator" {
  name       = "victoria-metrics-operator"
  repository = "https://victoriametrics.github.io/helm-charts"
  chart      = "victoria-metrics-operator"
  version    = "0.42.5"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      operator = {
        enable_converter_ownership = true
      }
      admissionWebhooks = {
        enabled = true
        certManager = {
          enabled = true
        }
      }
      crds = {
        enabled = false
      }
    })
  ]
}

resource "kubernetes_manifest" "victoria_metrics_cluster" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMCluster"
    metadata = {
      name      = "victoria-metrics-cluster"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-cluster"
      }
    }
    spec = {
      retentionPeriod   = "15"
      replicationFactor = 1

      vminsert = {
        replicaCount = 1
      }
      vmselect = {
        replicaCount = 1
      }
      vmstorage = {
        replicaCount = 1
        storage = {
          volumeClaimTemplate = {
            spec = {
              accessModes = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "10Gi"
                }
              }
              storageClassName = "lvmpv-xfs"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "victoria_metrics_agent" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMAgent"
    metadata = {
      name      = "victoria-metrics-agent"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-agent"
      }
    }
    spec = {
      selectAllByDefault = true
      remoteWrite = [
        {
          url = "http://vminsert-victoria-metrics-cluster.monitoring.svc:8480/insert/0/prometheus/api/v1/write"
        }
      ]
      scrapeInterval = "20s"
      externalLabels = {}
      extraArgs = {
        "promscrape.streamParse"        = "true"
        "promscrape.dropOriginalLabels" = "true"
      }
    }
  }
}

resource "kubernetes_manifest" "victoria_metrics_node_scrape_kubelet" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMNodeScrape"
    metadata = {
      name      = "victoria-metrics-node-scrape-kubelet"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-node-scrape-kubelet"
      }
    }
    spec = {
      scheme          = "https"
      honorLabels     = true
      interval        = "30s"
      scrapeTimeout   = "5s"
      honorTimestamps = false
      tlsConfig = {
        insecureSkipVerify = true
        caFile             = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
      }
      bearerTokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      # metricRelabelConfigs = [
      #   {
      #     action = "labeldrop"
      #     regex  = "(uid)"
      #   },
      #   {
      #     action = "labeldrop"
      #     regex  = "(id|name)"
      #   },
      #   {
      #     action       = "drop"
      #     sourceLabels = ["__name__"]
      #     regex        = "(rest_client_request_duration_seconds_bucket|rest_client_request_duration_seconds_sum|rest_client_request_duration_seconds_count)"
      #   }
      # ]
      relabelConfigs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        },
        {
          sourceLabels = ["__metrics_path__"]
          targetLabel  = "metrics_path"
        },
        {
          targetLabel = "job"
          replacement = "kubelet"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "victoria_metrics_node_scrape_cadvisor" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMNodeScrape"
    metadata = {
      name      = "victoria-metrics-node-scrape-cadvisor"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-node-scrape-cadvisor"
      }
    }
    spec = {
      scheme          = "https"
      honorLabels     = true
      interval        = "30s"
      scrapeTimeout   = "5s"
      honorTimestamps = false
      path            = "/metrics/cadvisor"
      tlsConfig = {
        insecureSkipVerify = true
        caFile             = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
      }
      bearerTokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      relabelConfigs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        },
        {
          sourceLabels = ["__metrics_path__"]
          targetLabel  = "metrics_path"
        },
        {
          targetLabel = "job"
          replacement = "cadvisor"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "victoria_metrics_node_scrape_probes" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMNodeScrape"
    metadata = {
      name      = "victoria-metrics-node-scrape-probes"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-node-scrape-probes"
      }
    }
    spec = {
      scheme          = "https"
      honorLabels     = true
      interval        = "30s"
      scrapeTimeout   = "5s"
      honorTimestamps = false
      path            = "/metrics/probes"
      tlsConfig = {
        insecureSkipVerify = true
        caFile             = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
      }
      bearerTokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      relabelConfigs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        },
        {
          sourceLabels = ["__metrics_path__"]
          targetLabel  = "metrics_path"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "victoria_metrics_node_scrape_resource" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMNodeScrape"
    metadata = {
      name      = "victoria-metrics-node-scrape-resource"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-node-scrape-resource"
      }
    }
    spec = {
      scheme          = "https"
      honorLabels     = true
      interval        = "30s"
      scrapeTimeout   = "5s"
      honorTimestamps = false
      path            = "/metrics/resource"
      tlsConfig = {
        insecureSkipVerify = true
        caFile             = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
      }
      bearerTokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      relabelConfigs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        },
        {
          sourceLabels = ["__metrics_path__"]
          targetLabel  = "metrics_path"
        },
      ]
    }
  }
}


resource "kubernetes_manifest" "victoria-metrics-alertmanager" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMAlertmanager"
    metadata = {
      name      = "victoria-metrics-alertmanager"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-alertmanager"
      }
    }
    spec = {
      replicaCount = 1
      configRawYaml = yamlencode({
        route = {
          receiver = "default"
        }
        receivers = [{
          name = "default"
          discord_configs = [{
            webhook_url   = var.discord_webhook_url
            send_resolved = true
            title         = "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
            message       = "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
          }]
        }]
      })
    }
  }
}

resource "kubernetes_manifest" "victoria-metrics-alert" {
  manifest = {
    apiVersion = "operator.victoriametrics.com/v1beta1"
    kind       = "VMAlert"
    metadata = {
      name      = "victoria-metrics-alert"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        name = "victoria-metrics-alert"
      }
    }
    spec = {
      replicaCount       = 1
      selectAllByDefault = true
      evaluationInterval = "15s"
      datasource = {
        url = "http://vmselect-victoria-metrics-cluster.monitoring.svc:8481/select/0/prometheus"
      }
      extraArgs = {
        enableTCP6 = "true"
      }
      remoteWrite = {
        url = "http://vminsert-victoria-metrics-cluster.monitoring.svc:8480/insert/0/prometheus/"
      }
      remoteRead = {
        url = "http://vmselect-victoria-metrics-cluster.monitoring.svc:8481/select/0/prometheus/"
      }
      notifier = {
        url = "http://vmalertmanager-victoria-metrics-alertmanager.monitoring.svc:9093"
        selector = {
          namespaceSelector = {
            any = true
          }
        }
      }
    }
  }
}
