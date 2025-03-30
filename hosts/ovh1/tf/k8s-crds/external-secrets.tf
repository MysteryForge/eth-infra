module "crd_external_secrets" {
  source = "../../../../modules/tf/k8s-crd"
  yaml = [
    file("${path.module}/crds/external-secrets.crds.yaml"),
  ]
}
