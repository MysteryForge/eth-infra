variable "discord_webhook_url" {
  description = "Discord Webhook URL"
  sensitive   = true
}

variable "oidc_grafana_secret" {
  description = "OIDC Secret"
  sensitive   = true
}

variable "grafana_host" {
  description = "The host URI"
  type        = string
}

variable "auth_roles_path" {
  description = "The path to the auth roles"
  type        = string
}
