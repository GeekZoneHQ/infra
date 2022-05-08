terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "geekzone"

    workspaces {
      name = "dev-azure"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

resource "azurerm_resource_group" "geekzone" {
  name     = "geekzone"
  location = "UK South"
}

resource "azurerm_private_dns_zone" "geekzone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.geekzone.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "geekzone" {
  name                  = "geekzone"
  resource_group_name   = azurerm_resource_group.geekzone.name
  private_dns_zone_name = azurerm_private_dns_zone.geekzone.name
  virtual_network_id    = azurerm_virtual_network.geekzone.id
  depends_on = [
    azurerm_resource_group.geekzone,
    azurerm_virtual_network.geekzone,
    azurerm_private_dns_zone.geekzone,
  ]
}

resource "azurerm_virtual_network" "geekzone" {
  name                = "geekzone"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.geekzone.location
  resource_group_name = azurerm_resource_group.geekzone.name
}

resource "azurerm_subnet" "aks" {
  name                 = "k8s-cluster"
  resource_group_name  = azurerm_resource_group.geekzone.name
  virtual_network_name = azurerm_virtual_network.geekzone.name
  address_prefixes     = ["10.10.1.0/24"]

}

resource "azurerm_subnet" "database" {
  name                 = "postgres"
  resource_group_name  = azurerm_resource_group.geekzone.name
  virtual_network_name = azurerm_virtual_network.geekzone.name
  address_prefixes     = ["10.10.2.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
  delegation {
    name = "geekzone"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/singleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

}

resource "azurerm_subnet" "endpoint" {
  name                 = "endpoint"
  resource_group_name  = azurerm_resource_group.geekzone.name
  virtual_network_name = azurerm_virtual_network.geekzone.name
  address_prefixes     = ["10.10.3.0/24"]

  enforce_private_link_endpoint_network_policies = true

}

module "aks" {
  source                           = "Azure/aks/azurerm"
  resource_group_name              = azurerm_resource_group.geekzone.name
  client_id                        = var.client_id
  client_secret                    = var.client_secret
  kubernetes_version               = "1.21.7"
  orchestrator_version             = "1.21.7"
  prefix                           = "prefix"
  cluster_name                     = "GeekZoneCluster"
  network_plugin                   = "azure"
  vnet_subnet_id                   = azurerm_subnet.aks.id
  os_disk_size_gb                  = 50
  sku_tier                         = "Paid" # defaults to Free
  enable_role_based_access_control = false
  rbac_aad_managed                 = false
  private_cluster_enabled          = false # default value
  enable_http_application_routing  = false
  enable_azure_policy              = true
  enable_auto_scaling              = true
  enable_host_encryption           = false
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "geekzone"
  agents_availability_zones        = ["1", "2", "3"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_tags = {
    "env" : "prod"
  }

  enable_ingress_application_gateway = false

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

  depends_on = [azurerm_resource_group.geekzone, resource.azurerm_virtual_network.geekzone]
}

resource "azurerm_postgresql_server" "geekzone" {
  name                         = "geekzone"
  location                     = azurerm_resource_group.geekzone.location
  resource_group_name          = azurerm_resource_group.geekzone.name
  sku_name                     = "GP_Gen5_2"
  storage_mb                   = 10240
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login              = var.administrator_login
  administrator_login_password     = var.administrator_login_password
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  public_network_access_enabled    = false
  tags = {
    "env" = "prod"
  }

}

resource "azurerm_postgresql_database" "geekzone" {
  name                = "geekzone"
  resource_group_name = azurerm_resource_group.geekzone.name
  server_name         = azurerm_postgresql_server.geekzone.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  depends_on = [
    azurerm_resource_group.geekzone,
    resource.azurerm_virtual_network.geekzone,
  ]
}

resource "azurerm_private_endpoint" "geekzone" {
  name                = "geekzone-endpoint"
  location            = azurerm_resource_group.geekzone.location
  resource_group_name = azurerm_resource_group.geekzone.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_dns_zone_group {
    name                 = "geekzone-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.geekzone.id]
  }

  private_service_connection {
    name                           = "geekzone-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.geekzone.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

}