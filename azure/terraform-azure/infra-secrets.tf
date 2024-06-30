data "hcp_project" "main" {
  project = var.project_id
}

resource "hcp_service_principal" "secret_reader" {
  name   = "secret-reader"
  parent = data.hcp_project.main.resource_name
}

resource "hcp_service_principal_key" "key" {
  service_principal = hcp_service_principal.secret_reader.resource_name
}

resource "hcp_vault_secrets_app" "infra" {
  app_name    = "infra"
  description = "App containing infra secrets"
  project_id  = data.hcp_project.main.resource_id
}

resource "hcp_project_iam_binding" "secret_reader" {
  project_id   = data.hcp_project.main.resource_id
  principal_id = hcp_service_principal.secret_reader.resource_id
  role         = "roles/secrets.app-secret-reader"
}

data "hcp_vault_secrets_secret" "azure_client_id" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "client_id"
}

data "hcp_vault_secrets_secret" "azure_client_password" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "client_password"
}

data "hcp_vault_secrets_secret" "subscription_id" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "subscription_id"
}

data "hcp_vault_secrets_secret" "tenant_id" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "tenant_id"
}

data "hcp_vault_secrets_secret" "docker_username" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "docker_username"
}

data "hcp_vault_secrets_secret" "docker_password" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "docker_password"
}

data "hcp_vault_secrets_secret" "terraform_token" {
  app_name    = hcp_vault_secrets_app.infra.app_name
  secret_name = "terraform_token"
}
