terraform {
  required_providers {
    cloudflare = { source = "cloudflare/cloudflare" }
    openstack  = { source = "terraform-provider-openstack/openstack" }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" # Authentication URL
  domain_name = "default"                        # Domain name - Always at 'default' for OVHcloud
  alias       = "ovh"                            # An alias
}
