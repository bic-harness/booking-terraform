
data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

resource "harness_platform_pipeline" "this" {
  identifier    = "${var.name}_${random_string.this.result}"
  org_id        = data.harness_platform_organization.this.id
  project_id    = data.harness_platform_project.this.id
  name          = var.name
  yaml          = <<-EOT
pipeline:
  name: ${var.name}
  identifier: "${var.name}_${random_string.this.result}"
  projectIdentifier: ${data.harness_platform_project.this.id}
  orgIdentifier: ${data.harness_platform_organization.this.id}
  tags: {}
  stages:
    - stage:
        name: DQS Deployment
        identifier: DQS_Deployment
        template:
          templateRef: "${var.type == "canary" ? "canary_kubernetes" : var.type}"
          versionLabel: v1
          templateInputs:
            type: Deployment
            spec:
              service:
                serviceRef: <+input>
                serviceInputs: <+input>
              environment:
                environmentRef: DQS
                infrastructureDefinitions:
                  - identifier: DQSCluster_qvlp
    - stage:
        name: Prod Approval
        identifier: Prod_Approval
        description: ""
        type: Approval
        spec:
          execution:
            steps:
              - step:
                  name: Approval for Prod Deployment
                  identifier: Approval_for_Prod_Deployment
                  type: HarnessApproval
                  timeout: 1d
                  spec:
                    approvalMessage: |-
                      Please review the following information
                      and approve the pipeline progression
                    includePipelineExecutionHistory: true
                    approvers:
                      minimumCount: 1
                      disallowPipelineExecutor: false
                      userGroups:
                        - account._account_all_users
                    isAutoRejectEnabled: false
                    approverInputs: []
        tags: {}
    - stage:
        name: Prod Deployment
        identifier: Prod_Deployment
        template:
          templateRef: canary_kubernetes
          versionLabel: v1
          templateInputs:
            type: Deployment
            spec:
              service:
                useFromStage:
                  stage: DQS_Deployment
              environment:
                environmentRef: Prod
                infrastructureDefinitions:
                  - identifier: ProdCluster_hbwj
  EOT
}
