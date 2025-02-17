locals {
  name            = var.name
  certs_name      = "${var.name}-certs"
  config_name     = "${var.name}-config"
  blockrelay_name = "${var.name}-blockrelay"
  metrics_name    = "${var.name}-metrics"
  svc_name        = var.name
}
