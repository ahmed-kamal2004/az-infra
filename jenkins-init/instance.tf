resource "azurerm_linux_virtual_machine" "jenkins" {
  name                  = "a7a-mad-vm"
  location              = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name   = azurerm_resource_group.jenkins-resource-group.name
  network_interface_ids = [azurerm_network_interface.jenkins-newtork-interface.id, ]
  size                  = "Standard_D2s_v3"

  admin_username = "devops"



  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  custom_data = base64encode(file("init.sh"))
  tags = {
    environment = "devops"
  }
}
