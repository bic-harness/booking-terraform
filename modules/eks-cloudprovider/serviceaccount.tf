resource "kubernetes_namespace" "harness" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account_v1" "delegate" {
  metadata {
    name      = "harness-delegate"
    namespace = try(kubernetes_namespace.harness[0].metadata[0].name, var.namespace)
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  depends_on = [kubernetes_service_account_v1.delegate]

  metadata {
    name        = "${try(kubernetes_namespace.harness[0].metadata[0].name, var.namespace)}harness-delegate-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.delegate.metadata[0].name
    namespace = try(kubernetes_namespace.harness[0].metadata[0].name, var.namespace)
  }

}


