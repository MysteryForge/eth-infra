
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "acme_email" {
  description = "email for ACME registration"
  type        = string
}

variable "cloudflare_email" {
  description = "email for Cloudflare"
  type        = string
}
