data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_region" "current" {}

data "harness_secret_manager" "default" {
  default = true
}

data "kubernetes_secret_v1" "sa_token" {
  metadata {
    name        = kubernetes_service_account_v1.delegate.default_secret_name
    namespace   = try(kubernetes_namespace.harness[0].metadata[0].name, var.namespace)
  }
}
