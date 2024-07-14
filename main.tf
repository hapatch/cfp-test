resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "cf-test-rg"
}

resource "azurerm_container_registry" "registry" {
  name                = "cfptestregistry007"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Create user assigned identity, and give it acrpull assignment
resource "azurerm_user_assigned_identity" "uid" {
  location            = azurerm_resource_group.rg.location
  name                = "uid"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "uid_acr_pull" {
  scope                = azurerm_container_registry.registry.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.uid.principal_id
  depends_on           = [
    azurerm_user_assigned_identity.uid
  ]
}

# Create virtual network
resource "azurerm_virtual_network" "test_vnetwork" {
  name                = "testVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "test_subnet" {
  name                 = "testSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.test_vnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the db network interface and group
resource "azurerm_network_interface" "db_nic" {
  name                = "dbNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "dbNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAppToDB"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
    destination_port_range     = "5432"
    source_port_range          = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "db_nic_nsg" {
  network_interface_id      = azurerm_network_interface.db_nic.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

# Create DB virtual machine
resource "azurerm_linux_virtual_machine" "db_vm" {
  name                  = "dbVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.db_nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "dbOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username
  admin_password = var.password
  custom_data  = base64encode(templatefile("${path.module}/db_startup.tpl", {uid_id = azurerm_user_assigned_identity.uid.id}))
  disable_password_authentication = false

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uid.id]
  }
}

# Create public IPs
resource "azurerm_public_ip" "app_public_ip" {
  name                = "appIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "app_nsg" {
  name                = "appNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allowSSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create network interface
resource "azurerm_network_interface" "network_interface" {
  name                = "vm_network_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                  = "appVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "appOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username
  admin_password = var.password
  custom_data  = base64encode(templatefile("${path.module}/app_startup.tpl", {uid_id = azurerm_user_assigned_identity.uid.id, db_ip=azurerm_network_interface.db_nic.private_ip_address}))
  disable_password_authentication = false

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uid.id]
  }
  depends_on = [
    azurerm_linux_virtual_machine.db_vm
  ]
}
