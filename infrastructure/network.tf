resource "azurerm_network_security_group" "aks-network-security-group" {
  name                = "aks-security-group"
  location            = azurerm_resource_group.aks-resource-group.location
  resource_group_name = azurerm_resource_group.aks-resource-group.name


  security_rule {
    name                       = "ssh-rule"
    priority                   = 100
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
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "jenkins-virtual-network" {
  name                = "aks-virtual-network"
  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    environment = "Pipeline"
  }
}


resource "azurerm_subnet" "jenkins-public-subnet" {
  resource_group_name  = azurerm_resource_group.jenkins-resource-group.name
  name                 = "jenkins-public-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.jenkins-virtual-network.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.jenkins-public-subnet.id
  network_security_group_id = azurerm_network_security_group.jenkins-network-security-group.id
}

resource "azurerm_network_interface" "jenkins-newtork-interface" {
  name = "jenkins-network-interface"

  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins-public-ip.id
  }
}



resource "azurerm_public_ip" "jenkins-public-ip" {
  name                = "jenkins-public-ip"
  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name
  allocation_method   = "Dynamic"
}
