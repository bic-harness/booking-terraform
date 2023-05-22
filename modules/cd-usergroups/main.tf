data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "harness_user_group" "execute" {
  name = "UAL-Harness-${var.technology_area}-${var.app_ci}-Execute-DGG"
}

resource "harness_user_group_permissions" "Execute" {
  user_group_id = data.harness_user_group.execute.id

  account_permissions = [
    "CREATE_CUSTOM_DASHBOARDS"
  ]

  app_permissions {

    all {
      actions = ["READ", "EXECUTE_WORKFLOW", "EXECUTE_PIPELINE", "ROLLBACK_WORKFLOW"]
      app_ids = [data.harness_application.this.id]
    }

  }
}

data "harness_user_group" "admin" {
  name = "UAL-Harness-${var.technology_area}-${var.app_ci}-Admin-DGG"
}

resource "harness_user_group_permissions" "Admin" {
  user_group_id = data.harness_user_group.admin.id

  account_permissions = [
    "CREATE_CUSTOM_DASHBOARDS"
  ]

  app_permissions {

    all {
      actions = ["READ", "EXECUTE_WORKFLOW", "EXECUTE_PIPELINE", "ROLLBACK_WORKFLOW"]
      app_ids = [data.harness_application.this.id]
    }

    template {
      actions = ["CREATE", "READ", "UPDATE", "DELETE"]
      app_ids = [data.harness_application.this.id]
    }

    workflow {
      actions = ["CREATE", "READ", "UPDATE", "DELETE"]
      app_ids = [data.harness_application.this.id]
      filters = ["NON_PRODUCTION_WORKFLOWS", "PRODUCTION_WORKFLOWS", "WORKFLOW_TEMPLATES"]
    }


    pipeline {
      actions = ["CREATE", "READ", "UPDATE", "DELETE"]
      app_ids = [data.harness_application.this.id]
      filters = ["NON_PRODUCTION_PIPELINES", "PRODUCTION_PIPELINES"]
    }

  }

}

