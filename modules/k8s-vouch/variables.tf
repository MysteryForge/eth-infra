variable "name" {
  description = "The name of the vouch instance"
}

variable "dirk_authority" {
  description = "The k8s secret name to authority certificate for the vouch instance"
  type        = string
}

variable "vouch_key" {
  description = "The path to the vouch key"
  type        = string
}

variable "vouch_crt" {
  description = "The path to the vouch certificate"
  type        = string
}

variable "namespace" {
  description = "The k8s namespace to deploy the vouch instance"
}

variable "beacon_node_addresses" {
  description = "YAML object of beacon node addresses"
  type        = string
}

variable "graffiti" {
  description = "The static graffiti"
  type        = string
}

variable "blockrelay_config" {
  description = "JSON object of blockrelay config"
  type        = string
}

variable "fallback_fee_recipient" {
  description = "The fallback fee recipient"
  type        = string
}

variable "dirk_endpoints" {
  description = "YAML object of dirk endpoints"
  type        = string
}

variable "wallets" {
  description = "YAML object of wallets"
  type        = string
}

