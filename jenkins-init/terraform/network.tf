resource "azurerm_network_security_group" "jenkins-network-security-group" {
  name                = "jenkins-security-group"
  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name


  security_rule {
    name                       = "ssh-rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # SourceAddressPrefixes, SourceAddressPrefix, or SourceApplicationSecurityGroups.
  security_rule {
    name                       = "http-rule"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "https-rule"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_virtual_network" "jenkins-virtual-network" {
  name                = var.jenkins-virtual-network-name
  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "jenkins-public-subnet" {
  resource_group_name  = azurerm_resource_group.jenkins-resource-group.name
  name                 = "jenkins-public-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.jenkins-virtual-network.name
}


resource "azurerm_public_ip" "jenkins-public-ip-master" {
  name                    = "jenkins-public-ip-master"
  location                = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name     = azurerm_resource_group.jenkins-resource-group.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_public_ip" "jenkins-public-ip-slave" {
  name                    = "jenkins-public-ip-slave"
  location                = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name     = azurerm_resource_group.jenkins-resource-group.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

