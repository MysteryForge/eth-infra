locals {
  # Split and parse individual CRD documents from YAML
  parsed_yaml_documents = [
    for document in [
      for yaml_content in split("\n---\n", join("\n---\n", var.yaml))
      : trim(yaml_content, "\n")
    ] : yamldecode(document) if document != ""
  ]

  # Filter out any null documents
  valid_crd_documents = [for doc in local.parsed_yaml_documents : doc if doc != null]

  # Create a map of CRDs using their names as keys
  crd_name_to_definition_map = { for doc in local.valid_crd_documents : doc.metadata.name => doc }
}

data "external" "cleaned_crd_definitions" {
  for_each = local.crd_name_to_definition_map

  program = ["python3", "${path.module}/cleanup.py"]

  query = {
    data = jsonencode(each.value)
  }
}

resource "kubernetes_manifest" "custom_resource_definitions" {
  for_each = data.external.cleaned_crd_definitions
  manifest = jsondecode(each.value.result.data)
}
