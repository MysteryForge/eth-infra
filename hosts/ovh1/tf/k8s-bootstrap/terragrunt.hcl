include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../k8s-crds"]
}