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

variable "erigon_pvc_size" {
  description = "The size of the erigon pvc"
  type        = string
}

variable "erigon_args" {
  description = "The arguments to pass to erigon, and make sure you dont owerwrite the data dir, jwt secret and ports"
  type        = list(string)
}

variable "erigon_image" {
  description = "The image to use for erigon"
  type        = string
}

variable "enable_probes" {
  description = "Enable liveness and readiness probes"
  type        = bool
  default     = true
}

variable "erigon_min_peers" {
  description = "The minimum number of peers to connect to"
  type        = number
  default     = 1
}
