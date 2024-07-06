terraform {
  cloud {
    organization = "geekzone"
    hostname     = "app.terraform.io"
    workspaces {
      name = "vault-secrets"
    }
  }
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.90.0"
    }
  }
}

provider "hcp" {
  client_id     = var.HCP_CLIENT_ID
  client_secret = var.HCP_CLIENT_SECRET
  project_id    = var.project_id
}

data "hcp_project" "main" {
  project = var.project_id
}

resource "hcp_service_principal" "secret_reader" {
  name   = "secret-reader"
  parent = data.hcp_project.main.resource_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "hcp_service_principal_key" "key" {
  service_principal = hcp_service_principal.secret_reader.resource_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "hcp_vault_secrets_app" "infra" {
  app_name    = "infra"
  description = "App containing infra secrets"
  project_id  = data.hcp_project.main.resource_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "hcp_project_iam_binding" "secret_reader" {
  project_id   = data.hcp_project.main.resource_id
  principal_id = hcp_service_principal.secret_reader.resource_id
  role         = "roles/secrets.app-secret-reader"
  lifecycle {
    prevent_destroy = true
  }
}
