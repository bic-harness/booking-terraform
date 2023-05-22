locals {
  cloud_provider_name = lower("${var.technology_area}-${var.app_ci}-${data.aws_region.current.name}-${var.cluster_name}")
  env_filter_types = {
    "prod": "PRODUCTION_ENVIRONMENTS",
    "nonprod": "NON_PRODUCTION_ENVIRONMENTS"
  }
}

resource "harness_encrypted_text" "token" {
  name              = "${local.cloud_provider_name}-sa-token"
  value             = data.kubernetes_secret_v1.sa_token.data["token"]
  secret_manager_id = data.harness_secret_manager.default.id

  usage_scope {
    application_id = data.harness_application.this.id
    environment_filter_type = env_filter_types[var.environment_type]
  }

}

resource "harness_cloudprovider_kubernetes" "this" {
  name            = local.cloud_provider_name
  skip_validation = var.skip_validation

  authentication {
    service_account {
      master_url = data.aws_eks_cluster.this.endpoint
      service_account_token_secret_name = harness_encrypted_text.token.name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
