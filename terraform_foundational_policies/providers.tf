# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.tfe_token
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
}