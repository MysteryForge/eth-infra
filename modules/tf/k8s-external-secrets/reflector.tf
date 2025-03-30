# secret reflector/duplicator
resource "helm_release" "reflector" {
  name       = "reflector"
  repository = "https://emberstack.github.io/helm-charts"
  chart      = "reflector"
  version    = "7.1.288"
  namespace  = "default"
  skip_crds  = true
}

