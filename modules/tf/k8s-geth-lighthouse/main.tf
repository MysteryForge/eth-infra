locals {
  name                = "node-${var.name}"
  jwt_name            = "${local.name}-jwt"
  geth_pvc_name       = "${local.name}-geth"
  lighthouse_pvc_name = "${local.name}-lighthouse"
}
