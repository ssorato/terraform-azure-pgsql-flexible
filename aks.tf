resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_parameters.name
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  dns_prefix          = "int${replace(var.aks_parameters.name,"[^a-zA-Z\\d]","")}"
  kubernetes_version  = var.aks_parameters.kubernetes_version

  default_node_pool {
    name                 = "${var.common_tags.sandbox}dpool"
    vm_size              = var.aks_parameters.defaultpool_vm_sku
    orchestrator_version = var.aks_parameters.kubernetes_version
    enable_auto_scaling  = false
    node_count           = var.aks_parameters.defaultpool_node_count
    os_disk_size_gb      = var.aks_parameters.os_disk_size_gb
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = data.azurerm_subnet.aks_subnet.id 
    node_labels = {
      "nodepool-type"    = "default"
      "environment"      = var.common_tags.environment
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
    } 
    tags = merge(
      {
        "nodepool-type"    = "default"
        "environment"      = var.common_tags.environment
        "nodepoolos"       = "linux"
        "name"             = "${var.common_tags.sandbox}dpool"
        "aks"              = var.aks_parameters.name
      },
      var.common_tags
    ) 
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = var.aks_parameters.admin_username
    ssh_key {
      key_data = file(var.aks_parameters.ssh_public_key_file)
    }
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = merge(
    {
      name        = var.aks_parameters.name
    },
    var.common_tags
  )

}

resource "azurerm_role_assignment" "role_system_subnet" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_subnet.aks_subnet.id
}
