variable "tfe_organization" {
  description = "Name of the Terraform organization"
}

variable "tfe_hostname" {
  description = "The Terraform Enterprise hostname to connect to. Defaults to app.terraform.io."
  default     = "app.terraform.io"
}

variable "tfe_token" {
  description = "The token used to authenticate with Terraform Enterprise"
}

variable "github_organization" {
  description = "This is the target GitHub organization to manage"
}

variable "github_token" {
  description = "This is the GitHub personal access token"
}

variable "github_oauth_token_id" {
  description = "The token string you were given by your VCS provider"
}

variable "gcp_keyfile_json_path" {
  description = "The path to or the contents of a service account key file in JSON format"
}

variable "gcp_project" {
  description = "The default project to manage resources in"
}

variable "gcp_region" {
  description = "The default region to manage resources in"
}
