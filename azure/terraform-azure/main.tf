terraform {
  cloud {
    organization = "geekzone"
    hostname     = "app.terraform.io"
    workspaces {
      name = "Azure"
    }
  }
}

provider "azurerm" {
  subscription_id = var.ARM_SUBSCRIPTION_ID
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  tenant_id       = var.ARM_TENANT_ID

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
    azurerm_subnet.database
  ]
}

resource "azurerm_virtual_network" "geekzone" {
  name                = "geekzone"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.geekzone.location
  resource_group_name = azurerm_resource_group.geekzone.name
}

resource "azurerm_network_security_group" "database" {
  name                = "geekzone-nsg"
  location            = azurerm_resource_group.geekzone.location
  resource_group_name = azurerm_resource_group.geekzone.name

  security_rule {
    name                       = "allow-all-tcp-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
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
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.database.id
}

resource "azurerm_subnet" "endpoint" {
  name                 = "endpoint"
  resource_group_name  = azurerm_resource_group.geekzone.name
  virtual_network_name = azurerm_virtual_network.geekzone.name
  address_prefixes     = ["10.10.3.0/24"]

  private_endpoint_network_policies_enabled = true

}

module "aks" {
  source                            = "Azure/aks/azurerm"
  resource_group_name               = azurerm_resource_group.geekzone.name
  client_id                         = var.ARM_CLIENT_ID
  client_secret                     = var.ARM_CLIENT_SECRET
  kubernetes_version                = var.kubernetes_version
  orchestrator_version              = var.orchestrator_version
  prefix                            = "prefix"
  cluster_name                      = var.cluster_name
  network_plugin                    = "azure"
  vnet_subnet_id                    = azurerm_subnet.aks.id
  os_disk_size_gb                   = 50
  sku_tier                          = "Standard"
  role_based_access_control_enabled = false
  rbac_aad                          = false
  rbac_aad_managed                  = false
  private_cluster_enabled           = false # default value
  http_application_routing_enabled  = false
  azure_policy_enabled              = true
  public_network_access_enabled     = false
  enable_auto_scaling               = true
  enable_host_encryption            = false
  agents_min_count                  = 1
  agents_max_count                  = 2
  agents_count                      = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                   = 100
  agents_pool_name                  = "geekzone"
  agents_availability_zones         = ["1", "2", "3"]
  agents_type                       = "VirtualMachineScaleSets"

  agents_tags = {
    "env" : "prod"
  }

  network_policy             = "azure"
  net_profile_dns_service_ip = "10.0.0.10"
  net_profile_service_cidr   = "10.0.0.0/16"

  depends_on = [azurerm_resource_group.geekzone, resource.azurerm_virtual_network.geekzone]
}

resource "azurerm_postgresql_flexible_server" "geekzone" {
  name                = "geekzone"
  resource_group_name = azurerm_resource_group.geekzone.name
  location            = azurerm_resource_group.geekzone.location
  version             = "15"
  delegated_subnet_id = azurerm_subnet.database.id
  private_dns_zone_id = azurerm_private_dns_zone.geekzone.id
  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_login_password
  zone                   = "1"
  storage_mb             = 32768
  backup_retention_days  = 7
  sku_name               = "GP_Standard_D2s_v3"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.geekzone]

}

resource "azurerm_postgresql_flexible_server_database" "geekzone" {
  name      = "geekzone"
  server_id = azurerm_postgresql_flexible_server.geekzone.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
