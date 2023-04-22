output "pgsql_name" {
  value = azurerm_postgresql_flexible_server.pgsql_flexible.name
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.pgsql_flexible_db[0].name
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
