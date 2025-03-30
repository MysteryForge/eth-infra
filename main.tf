module "ovh_servers" {
  source           = "./modules/tf/ovh-dedicated"
  for_each         = toset(var.ovh_nodes)
  dedicated_server = each.key
  ssh_key_file     = file("./users/zeth/authorized_keys")
}
