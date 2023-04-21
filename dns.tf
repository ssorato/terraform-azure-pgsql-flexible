resource "azurerm_private_dns_zone" "pgsql_flexible_dns_zone" {
  name                = "pgsql-flexible-dns-zone.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  depends_on = [azurerm_subnet_network_security_group_association.subnet_pgsql_flexible_nsg]

  tags = merge(
    {
      name = "pgsql-flexible-dns-zone.postgres.database.azure.com"
    },
    var.common_tags
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgsql_flexible_dns_zone_vnetlink" {
  name                  = "pgsql-flexible-vnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.pgsql_flexible_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.rg_vnet.id
  resource_group_name   = data.azurerm_resource_group.azure_rg.name

  tags = merge(
    {
      name = "pgsql-flexible-vnetlink.com"
    },
    var.common_tags
  )
}
