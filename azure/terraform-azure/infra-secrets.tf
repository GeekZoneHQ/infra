resource "hcp_service_principal" "infra_reader" {
  name = "infra-reader"
}

resource "hcp_vault_secrets_app_iam_binding" "infra_reader" {
  resource_name = data.hcp_vault_secrets_app.infra.app_name
  principal_id  = hcp_service_principal.infra_reader.resource_id
  role          = "roles/secrets.app-secret-reader"
}

data "hcp_vault_secrets_secret" "azure_client_id" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "client_id"
}

data "hcp_vault_secrets_secret" "azure_client_password" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "client_password"
}

data "hcp_vault_secrets_secret" "subscription_id" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "subscription_id"
}

data "hcp_vault_secrets_secret" "tenant_id" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "tenant_id"
}

data "hcp_vault_secrets_secret" "docker_username" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "docker_username"
}

data "hcp_vault_secrets_secret" "docker_password" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "docker_password"
}

data "hcp_vault_secrets_secret" "terraform_token" {
  app_name    = data.hcp_vault_secrets_app.infra.app_name
  secret_name = "terraform_token"
}

