data "azurerm_resource_group" "azure_rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "rg_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.azure_rg.name
}

data "azurerm_subnet" "vm_subnet" {
  resource_group_name   = var.rg_name
  virtual_network_name  = var.vnet_name
  name                  = var.vm_parameters.subnet_name
}

resource "azurerm_subnet" "subnet_pgsql_flexible" {
  name                 = var.subnet_pgsql_flexible_name
  virtual_network_name = data.azurerm_virtual_network.rg_vnet.name
  resource_group_name  = data.azurerm_resource_group.azure_rg.name
  address_prefixes     = [var.subnet_pgsql_flexible_cidr]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "subnet_pgsql_flexible_delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "nsg_pgsql_flexible" {
  name                = "${var.pgsql_flexible_params.name}-nsg"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  security_rule {
    name                       = "pgsql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = merge(
    {
      name = "${var.pgsql_flexible_params.name}-nsg"
    },
    var.common_tags
  )
}

resource "azurerm_subnet_network_security_group_association" "subnet_pgsql_flexible_nsg" {
  subnet_id                 = azurerm_subnet.subnet_pgsql_flexible.id
  network_security_group_id = azurerm_network_security_group.nsg_pgsql_flexible.id
}