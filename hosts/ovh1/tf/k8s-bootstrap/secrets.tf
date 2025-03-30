data "sops_file" "secrets" {
  source_file = "./secrets.yaml"
}

output "sops_data" {
  value     = data.sops_file.secrets.data
  sensitive = true
}
