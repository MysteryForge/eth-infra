module "crd_victoria_metrics" {
  source = "../../../../modules/tf/k8s-crd"
  yaml = [
    file("${path.module}/crds/victoria-metrics.crds.yaml"),
  ]
}
