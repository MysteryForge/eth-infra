module "openebs" {
  source = "../../../../modules/tf/k8s-openebs"
}

module "cert_manager" {
  source               = "../../../../modules/tf/k8s-cert-manager"
  cloudflare_api_token = data.sops_file.secrets.data["cloudflare_api_token"]
  acme_email           = data.sops_file.secrets.data["acme_email"]
  cloudflare_email     = data.sops_file.secrets.data["cloudflare_email"]
}

module "ingress_nginx" {
  source = "../../../../modules/tf/k8s-ingress-nginx"
}

module "external_dns" {
  source               = "../../../../modules/tf/k8s-external-dns"
  cloudflare_api_token = data.sops_file.secrets.data["cloudflare_api_token"]
}

module "external_secrets" {
  source = "../../../../modules/tf/k8s-external-secrets"
}

module "doppler" {
  source        = "../../../../modules/tf/k8s-doppler"
  doppler_token = data.sops_file.secrets.data["doppler_token"]
}

module "oidc" {
  source               = "../../../../modules/tf/k8s-dex-oidc"
  github_client_id     = data.sops_file.secrets.data["github_client_id"]
  github_client_secret = data.sops_file.secrets.data["github_client_secret"]
  oidc_grafana_secret  = data.sops_file.secrets.data["oidc_grafana_secret"]
  issuer_host          = "my-domain.com" # change this to your server's domain
  org_name             = "ORG"           # change this to your organization
}

module "monitoring" {
  depends_on = [
    module.openebs,
    module.oidc
  ]
  source              = "../../../../modules/tf/k8s-monitoring"
  discord_webhook_url = data.sops_file.secrets.data["discord_webhook_url"]
  oidc_grafana_secret = data.sops_file.secrets.data["oidc_grafana_secret"]
  grafana_host        = "my-domain.com"                                          # change this to your server's domain
  auth_roles_path     = "contains(groups[*], 'ORG:Team') && 'Admin' || 'Viewer'" # change this to your team
}

module "cnpg" {
  source = "../../../../modules/tf/k8s-cloudnative-pg"
}

module "ghcr" {
  source     = "../../../../modules/tf/k8s-ghcr"
  ghcr_token = data.sops_file.secrets.data["ghcr_token"]
}
