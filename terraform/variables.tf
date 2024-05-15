variable "yc_token" {
  type = string
  description = "yc iam create-token"
}

variable "k8s_cluster_name" {
  type = string
  description = "K8S Cluster Name"
  default = "k8s-cluster-terraform-dev"
}
