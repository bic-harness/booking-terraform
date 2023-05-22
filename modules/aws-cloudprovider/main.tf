resource "harness_cloudprovider_aws" "aws" {
  name              = lower("${var.technology_area}-${var.tier}-${var.app_ci}-aws")
  delegate_selector = coalesce(var.delegate_selector, "${var.technology_area}-${var.tier}")
  use_irsa = var.irsa_enabled

  assume_cross_account_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.cross_account_role_name}"
    external_id = var.cross_account_role_external_id
  }
}
