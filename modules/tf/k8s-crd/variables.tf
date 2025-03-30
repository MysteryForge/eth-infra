variable "yaml" {
  description = "List of YAML strings containing Kubernetes Custom Resource Definitions"
  type        = list(string)
  default     = []
}
