variable "ovh_nodes" {
  description = "List of OVH server IPs"
  type        = list(string)
}

variable "cloudflare_zone_id" {
  description = "Zone identifier for Cloudflare domain configuration"
  type        = string
}

variable "cloudflare_zone_name" {
  description = "DNS zone name registered in Cloudflare"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Unique identifier for Cloudflare account"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Authentication token for Cloudflare API access"
  type        = string
  sensitive   = true
}
