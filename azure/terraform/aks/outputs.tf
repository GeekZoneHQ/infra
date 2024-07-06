output "resource_group_name" {
  value = azurerm_resource_group.geekzone.name
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.geekzone.name
}

output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.geekzone.name
}
