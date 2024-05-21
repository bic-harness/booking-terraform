module "k8s_connector" {
  source  = "app.terraform.io/empire/modules/harness//modules/connectors"
  version = "1.0.0"
  team_name = var.team_name
  organization_id = var.organization_id
}