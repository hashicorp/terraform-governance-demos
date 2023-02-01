# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# ------------------------------------------------  
# Provision Kubernetes Foundational Policy Set 
# ------------------------------------------------  
resource "github_repository" "repo_policies" {
  name         = "cis-gcp-kubernetes-foundational-policies"
  description  = "Source respository for the cis-gcp-kubernetes-foundational-policies Policy Set in Terraform Cloud"
  homepage_url = "https://github.com/hashicorp/terraform-foundational-policies-library"
  private      = true
  auto_init    = true
}

resource "github_repository_file" "file_sentinel" {
  repository = github_repository.repo_policies.name
  file       = "sentinel.hcl"
  content    = file("${path.module}/sentinel.hcl")
  commit_message = "Bootstrapping Policy Set demonstration"
}

resource "tfe_policy_set" "policy_set" {
  name         = github_repository.repo_policies.name
  description  = "Policy Set, to demonstrate the Terraform CIS policies for Kubernetes"
  organization = var.tfe_organization
  workspace_ids = []

  vcs_repo {
    identifier         = github_repository.repo_policies.full_name
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = var.github_oauth_token_id
  }
}

# ------------------------------------------------  
# Provision GCP Kubernetes Cluster Resources 
# ------------------------------------------------  
resource "github_repository" "repo_kube" {
  name         = "demo-gcp-kubernetes-cluster"
  description  = "Source respository for the demo-gcp-kubernetes-cluster provisioned in Terraform Cloud"
  homepage_url = "https://github.com/hashicorp/terraform-foundational-policies-library"
  private      = true
  auto_init    = true
}

resource "github_repository_file" "file_config" {
  for_each       = fileset(path.module, "example/*")
  repository     = github_repository.repo_kube.name
  file           = trimprefix(each.value, "example/")
  content        = file(each.value)
  commit_message = "Bootstrapping Kubernetes demonstration"
}

resource "tfe_workspace" "kube" {
  name         = github_repository.repo_kube.name
  organization = var.tfe_organization

  vcs_repo {
    identifier         = github_repository.repo_kube.full_name
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = var.github_oauth_token_id
  }

  depends_on = [github_repository_file.file_config]
}

resource "tfe_variable" "gcp_credentials" {
  key          = "GOOGLE_CREDENTIALS"
  value        = jsonencode(jsondecode(file(var.gcp_keyfile_json_path)))
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.kube.id
}

resource "tfe_variable" "gcp_project" {
  key          = "GOOGLE_PROJECT"
  value        = var.gcp_project
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.kube.id
}

resource "tfe_variable" "gcp_region" {
  key          = "GOOGLE_REGION"
  value        = var.gcp_region
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.kube.id
}
