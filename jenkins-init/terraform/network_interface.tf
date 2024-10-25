resource "azurerm_network_interface" "jenkins-newtork-interface-master" {
  name = "jenkins-network-interface-master"

  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name

  ip_configuration {
    name                          = "internal-master"
    subnet_id                     = azurerm_subnet.jenkins-public-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.jenkins-public-ip-master.id
  }
}



resource "azurerm_network_interface" "jenkins-newtork-interface-slave" {
  name = "jenkins-network-interface-slave"

  location            = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name = azurerm_resource_group.jenkins-resource-group.name

  ip_configuration {
    name                          = "internal-slave"
    subnet_id                     = azurerm_subnet.jenkins-public-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
    public_ip_address_id          = azurerm_public_ip.jenkins-public-ip-slave.id
  }
}



resource "azurerm_network_interface_security_group_association" "jenkins-network-interface-sec-assoc-master" {
  network_interface_id      = azurerm_network_interface.jenkins-newtork-interface-master.id
  network_security_group_id = azurerm_network_security_group.jenkins-network-security-group.id
}

resource "azurerm_network_interface_security_group_association" "jenkins-network-interface-sec-assoc-slave" {
  network_interface_id      = azurerm_network_interface.jenkins-newtork-interface-slave.id
  network_security_group_id = azurerm_network_security_group.jenkins-network-security-group.id
}
