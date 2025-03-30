locals {
  name            = "node-${var.name}"
  jwt_name        = "${local.name}-jwt"
  erigon_pvc_name = "${local.name}-erigon"
}
