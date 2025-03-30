locals {
  version = "v0.78.1"
  crds_prometheus = [
    "monitoring.coreos.com_alertmanagerconfigs",
    "monitoring.coreos.com_alertmanagers",
    "monitoring.coreos.com_podmonitors",
    "monitoring.coreos.com_probes",
    "monitoring.coreos.com_prometheuses",
    "monitoring.coreos.com_prometheusrules",
    "monitoring.coreos.com_servicemonitors",
    "monitoring.coreos.com_thanosrulers",
  ]
}

data "http" "crd_prometheus_sources" {
  for_each = toset(local.crds_prometheus)
  url      = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/${each.value}.yaml"
}

module "crd_prometheus" {
  source = "../../../../modules/tf/k8s-crd"
  yaml   = [for k, v in data.http.crd_prometheus_sources : v.response_body]
}

