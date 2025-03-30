# data "helm_template" "openebs" {
#   name         = "openebs"
#   repository   = "https://openebs.github.io/charts"
#   chart        = "openebs"
#   version      = "3.10.0"
#   include_crds = true
#   values = [yamlencode({
#     lvm-localpv = {
#       enabled = true
#     }
#   })]
# }

# module "openebs_crd" {
#   source = "../k8s-crd"
#   yaml   = [for v in data.helm_template.openebs.crds : yamlencode(yamldecode(v))]
# }
