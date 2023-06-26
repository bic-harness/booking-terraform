// This is a hack to get around the soft-delete problem with Harness.
resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

resource "aws_ecs_cluster" "this" {
  name = "${var.team_name}Cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}