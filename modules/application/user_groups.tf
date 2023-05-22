// data "harness_sso_provider" "this" {
//   name = local.global_config["sso_provider_name"]
// }

// resource "harness_user_group" "Execute" {
//   name = "${var.technology_area}-${var.app_ci}-Execute"

//   ldap_settings {
//     sso_provider_id = data.harness_sso_provider.this.id
//     group_name = "ual-Harness-${var.technology_area}-${var.app_ci}-Execute-DGG"
//     group_dn = local.global_config["sso_group_dn"]
//   }

//   permissions {

//     account_permissions = [
//       "CREATE_CUSTOM_DASHBOARDS"
//     ]

//     app_permissions {
      
//       all {
//         actions = ["READ", "EXECUTE_WORKFLOW", "EXECUTE_PIPELINE", "ROLLBACK_WORKFLOW"]
//         app_ids = [harness_application.this.id]
//       }

//     }

//   }
// }

// resource "harness_user_group" "Admin" {
//   name = "${var.technology_area}-${var.app_ci}-Admin"

//   ldap_settings {
//     sso_provider_id = data.harness_sso_provider.this.id
//     group_name = "ual-Harness-${var.technology_area}-${var.app_ci}-Admin-DGG"
//     group_dn = local.global_config["sso_group_dn"]
//   }

//   permissions {

//     account_permissions = [
//       "CREATE_CUSTOM_DASHBOARDS"
//     ]

//     app_permissions {
      
//       all {
//         actions = ["READ", "EXECUTE_WORKFLOW", "EXECUTE_PIPELINE", "ROLLBACK_WORKFLOW"]
//         app_ids = [harness_application.this.id]
//       }

//       template {
//         actions = ["CREATE", "READ", "UPDATE", "DELETE"]
//         app_ids = [harness_application.this.id]
//       }

//       workflow {
//         actions = ["CREATE", "READ", "UPDATE", "DELETE"]
//         app_ids = [harness_application.this.id]
//         filters = ["NON_PRODUCTION_WORKFLOWS", "PRODUCTION_WORKFLOWS", "WORKFLOW_TEMPLATES"]
//       }
      

//       pipeline {
//         actions = ["CREATE", "READ", "UPDATE", "DELETE"]
//         app_ids = [harness_application.this.id]
//         filters = ["NON_PRODUCTION_PIPELINES", "PRODUCTION_PIPELINES"]
//       }
      
//     }

//   }
// }


