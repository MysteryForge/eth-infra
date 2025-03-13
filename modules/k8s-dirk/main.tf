locals {
  svc_name    = var.name
  sts_name    = "${var.name}-sts"
  pvc_name    = "${var.name}-xfs"
  certs_name  = "${var.name}-certs"
  config_name = "${var.name}-config"
  host        = "${var.name}:13141"
}
