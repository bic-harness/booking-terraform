// This is a hack to get around the soft-delete problem with Harness.
resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

resource "harness_platform_organization" "this" {
  identifier = "${var.technology_area}_${random_string.this.result}"
  name = var.technology_area
}
