# EKS Cloud Provider

This module will create a Cloud Provider for an EKS cluster. It is assumed that the IAM role used to execute this module has admin access to the target EKS cluster. It will look up the cluster credentials through the API and then install the Harness service account.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |
| <a name="requirement_harness"></a> [harness](#requirement\_harness) | ~> 0.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.11.0 |
| <a name="provider_harness"></a> [harness](#provider\_harness) | 0.2.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harness_cloudprovider_kubernetes.example](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/cloudprovider_kubernetes) | resource |
| [harness_encrypted_text.token](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/encrypted_text) | resource |
| [kubernetes_cluster_role_binding.admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.harness](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account_v1.delegate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [harness_application.this](https://registry.terraform.io/providers/harness/harness/latest/docs/data-sources/application) | data source |
| [harness_secret_manager.default](https://registry.terraform.io/providers/harness/harness/latest/docs/data-sources/secret_manager) | data source |
| [kubernetes_secret_v1.sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_ci"></a> [app\_ci](#input\_app\_ci) | The UAL AppCI. | `any` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The EKS Cluster to connect to. | `any` | n/a | yes |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it doesn't exist. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to create the Harness service account in. | `string` | `"harness-delegate"` | no |
| <a name="input_skip_validation"></a> [skip\_validation](#input\_skip\_validation) | Wether or not to skip the validation of the cloud provider. | `bool` | `false` | no |
| <a name="input_technology_area"></a> [technology\_area](#input\_technology\_area) | The UAL Technology Area. | `any` | n/a | yes |

## Outputs

No outputs.
