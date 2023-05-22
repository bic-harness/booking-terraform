// This is a hack to get around the soft-delete problem with Harness.
resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

resource "harness_platform_organization" "this" {
  identifier = "${var.team_name}_${random_string.this.result}"
  name = var.team_name
}
