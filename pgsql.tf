resource "azurerm_postgresql_flexible_server" "pgsql_flexible" {
  name                   = var.pgsql_flexible_params.name
  resource_group_name    = data.azurerm_resource_group.azure_rg.name
  location               = data.azurerm_resource_group.azure_rg.location
  version                = "${var.pgsql_flexible_params.version}"
  delegated_subnet_id    = azurerm_subnet.subnet_pgsql_flexible.id
  private_dns_zone_id    = azurerm_private_dns_zone.pgsql_flexible_dns_zone.id
  administrator_login    = var.pgsql_flexible_credentials.admin_login
  administrator_password = var.pgsql_flexible_credentials.admin_password
  storage_mb             = var.pgsql_flexible_params.storage_mb
  sku_name               = var.pgsql_flexible_params.sku_name
  backup_retention_days  = var.pgsql_flexible_params.backup_retention_days
  zone                   = "1"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.pgsql_flexible_dns_zone_vnetlink]

  tags = merge(
    {
      name = var.pgsql_flexible_params.name
    },
    var.common_tags
  )
}

resource "azurerm_postgresql_flexible_server_database" "pgsql_flexible_db" {
  count = var.pgsql_flexible_params.db_name == null ? 0 : 1
  name      = var.pgsql_flexible_params.db_name
  server_id = azurerm_postgresql_flexible_server.pgsql_flexible.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}