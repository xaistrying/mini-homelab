# ------------------------------------------------------------
# BASE INFRASTRUCTURE
# ------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.159.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

# ------------------------------------------------------------
# GATEWAY LAYER
# ------------------------------------------------------------

resource "azurerm_subnet" "snet_gateway" {
  name                 = "snet-gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.159.1.0/24"]
}

resource "azurerm_public_ip" "pip_gateway" {
  name                = "pip-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  domain_name_label   = "xaistrying-gateway"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "nic_gateway" {
  name                = "nic-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_gateway.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.159.1.4"
    public_ip_address_id          = azurerm_public_ip.pip_gateway.id
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "nsg_gateway" {
  name                = "nsg-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_gateway" {
  subnet_id                 = azurerm_subnet.snet_gateway.id
  network_security_group_id = azurerm_network_security_group.nsg_gateway.id
}

resource "azurerm_linux_virtual_machine" "vm_gateway" {
  name                = "vm-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_gateway_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_gateway.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1

  tags = local.common_tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_gateway" {
  virtual_machine_id = azurerm_linux_virtual_machine.vm_gateway.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "2200"
  timezone              = "SE Asia Standard Time"

  notification_settings {
    enabled = false
  }
}

# ------------------------------------------------------------
# APPLICATION LAYER
# ------------------------------------------------------------

resource "azurerm_subnet" "snet_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.159.5.0/24"]
}

resource "azurerm_network_interface" "nic_app" {
  name                = "nic-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.159.5.4"
  }

  tags = local.common_tags
}

resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSHFromGateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.159.1.0/24"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_app" {
  subnet_id                 = azurerm_subnet.snet_app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

resource "azurerm_linux_virtual_machine" "vm_app" {
  name                = "vm-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_app_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_app.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1

  tags = local.common_tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_app" {
  virtual_machine_id = azurerm_linux_virtual_machine.vm_app.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "2200"
  timezone              = "SE Asia Standard Time"

  notification_settings {
    enabled = false
  }
}
