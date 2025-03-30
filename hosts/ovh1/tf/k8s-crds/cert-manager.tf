module "crd_cert_manager" {
  source = "../../../../modules/tf/k8s-crd"
  yaml = [
    file("${path.module}/crds/cert-manager.crds.yaml"),
  ]
}
