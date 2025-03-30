variable "uid" {
  description = "The number of the dirk instance"
  default     = 1
}

variable "name" {
  description = "The name of the dirk instance"
}

variable "dirk_crt" {
  description = "The path to the dirk certificate"
  type        = string
}

variable "dirk_key" {
  description = "The path to the dirk key"
  type        = string
}

variable "namespace" {
  description = "The k8s namespace to deploy the dirk instance"
}

variable "dirk_authority" {
  description = "The k8s secret name to authority certificate for the dirk instance"
}

variable "wallet_passphrase" {
  description = "The k8s secret name to wallet passphrase for the dirk instance"
}

variable "account_passphrase" {
  description = "The k8s secret name to account passphrase for the dirk instance"
}

variable "wallet_type" {
  description = "The type of the wallet"
  type        = string
}

variable "wallet_name" {
  description = "The name of the wallet"
  type        = string
}

variable "peers" {
  description = "YAML object of peers"
  type        = string
}

variable "permissions" {
  description = "YAML object of permissions"
  type        = string
}
