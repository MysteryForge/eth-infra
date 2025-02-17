variable "name" {
  description = "The unique 3 letter name of the node"
  type        = string
}

variable "host" {
  description = "The host name of the node"
  type        = string
}

variable "eth_network" {
  description = "The network the node is running on(mainnet, holesky)"
  type        = string
}

variable "basic_auth_secret_name" {
  description = "The name of the basic auth secret"
  type        = string
}

variable "namespace" {
  description = "The namespace the node is running in"
  type        = string
}

variable "geth_pvc_size" {
  description = "The size of the geth pvc"
  type        = string
}

variable "lighthouse_pvc_size" {
  description = "The size of the lighthouse pvc"
  type        = string
}

variable "geth_args" {
  description = "The arguments to pass to geth, make sure that your data dir is /data/geth and your jwt secret is /jwtsecret"
  type        = list(string)
}

variable "lighthouse_args" {
  description = "The arguments to pass to lighthouse, make sure that your data dir is /data/lighthouse and your jwt secret is /jwtsecret"
  type        = list(string)
}

variable "geth_image" {
  description = "The image to use for geth"
  type        = string
}

variable "lighthouse_image" {
  description = "The image to use for lighthouse"
  type        = string
}
