data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.vm_parameters.name}-nsg"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = var.rg_name

  security_rule {
      name                       = "SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
      name                       = "SSH_external"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      destination_address_prefix = "VirtualNetwork"
  }

  tags = merge(
    {
      name        = "${var.vm_parameters.name}-nsg"
    },
    var.common_tags
  )
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.vm_parameters.name}-public-ip"
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "vm_nic" {
  name                      = "${var.vm_parameters.name}-nic"
  location                  = data.azurerm_resource_group.azure_rg.location
  resource_group_name       = data.azurerm_resource_group.azure_rg.name

  ip_configuration {
      name                          = "${var.vm_parameters.name}-nic-config"
      subnet_id                     = data.azurerm_subnet.vm_subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = merge(
    {
      name        = "${var.vm_parameters.name}-nic"
    },
    var.common_tags
  )
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

data "template_file" "config_tp" {
  template = "${file("files/cloud_init.tpl")}"
}

data "template_cloudinit_config" "config_agent" {                               
  gzip = true                                                                   
  base64_encode = true                                                          
                                                                                
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.config_tp.rendered
  }                                                                       
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_parameters.name
  location              = data.azurerm_resource_group.azure_rg.location
  resource_group_name   = data.azurerm_resource_group.azure_rg.name
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  size                  = "Standard_B1ls"

  os_disk {
      name                  = "${var.vm_parameters.name}-osdisk"
      caching               = "ReadOnly"
      storage_account_type  = "StandardSSD_LRS"
      disk_size_gb          = 30
  }

  source_image_reference {
      publisher = "Oracle"
      offer     = "Oracle-Linux"
      sku       = "ol79-lvm-gen2"
      version   = "latest"
  }

  computer_name                   = var.vm_parameters.name
  admin_username                  = var.vm_parameters.admin_username
  disable_password_authentication = true
  custom_data                     = data.template_cloudinit_config.config_agent.rendered

  admin_ssh_key {
      username    = var.vm_parameters.admin_username
      public_key  = file(var.vm_parameters.ssh_public_key_file)
  }

  tags = merge(
    {
      name        = var.vm_parameters.name
    },
    var.common_tags
  )
}
