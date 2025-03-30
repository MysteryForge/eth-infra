data "ovh_dedicated_server" "server" {
  service_name = var.dedicated_server
}

data "ovh_dedicated_server_boots" "rescue" {
  service_name = var.dedicated_server
  boot_type    = "rescue"
}

resource "ovh_dedicated_server_reinstall_task" "server_reinstall" {
  service_name      = var.dedicated_server
  os                = "debian12_64"
  bootid_on_destroy = data.ovh_dedicated_server_boots.rescue.result[0]
  customizations {
    hostname = var.dedicated_server
    ssh_key  = var.ssh_key_file
  }
}
