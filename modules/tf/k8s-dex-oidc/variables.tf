variable "github_client_id" {
  description = "GitHub OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "oidc_grafana_secret" {
  description = "OIDC Secret"
  type        = string
  sensitive   = true
}

variable "issuer_host" {
  description = "Issuer host"
  type        = string
}

variable "org_name" {
  description = "GitHub Organization Name"
  type        = string
}
