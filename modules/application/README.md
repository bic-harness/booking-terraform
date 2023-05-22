# Application

This Terraform module creates a new application and user groups for an AppCI within Harness.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_harness"></a> [harness](#requirement\_harness) | ~> 0.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_harness"></a> [harness](#provider\_harness) | 0.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harness_application.this](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/application) | resource |
| [harness_user_group.Admin](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/user_group) | resource |
| [harness_user_group.Execute](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/user_group) | resource |
| [harness_yaml_config.defaults](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/yaml_config) | resource |
| [harness_sso_provider.this](https://registry.terraform.io/providers/harness/harness/latest/docs/data-sources/sso_provider) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_ci"></a> [app\_ci](#input\_app\_ci) | The UAL AppCI. | `any` | n/a | yes |
| <a name="input_docker_artifactory_base_url"></a> [docker\_artifactory\_base\_url](#input\_docker\_artifactory\_base\_url) | The Docker Artifactory base URL. | `any` | n/a | yes |
| <a name="input_sso_group_dn"></a> [sso\_group\_dn](#input\_sso\_group\_dn) | The SSO group DN configured in Harness. | `any` | n/a | yes |
| <a name="input_sso_provider_name"></a> [sso\_provider\_name](#input\_sso\_provider\_name) | The SSO provider name configured in Harness. | `any` | n/a | yes |
| <a name="input_technology_area"></a> [technology\_area](#input\_technology\_area) | The UAL Technology Area. | `any` | n/a | yes |

## Outputs

No outputs.
