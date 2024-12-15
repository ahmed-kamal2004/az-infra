resource "azurerm_linux_virtual_machine" "jenkins-master" {
  name                  = "jenkins-master-vm"
  location              = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name   = azurerm_resource_group.jenkins-resource-group.name
  network_interface_ids = [azurerm_network_interface.jenkins-newtork-interface-master.id, ]
  size                  = "Standard_E2s_v3"

  admin_username = "devops"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "myosdisk1"
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 64
  }

  admin_ssh_key {
    username   = "devops"
    public_key = file("../id_rsa.pub")
  }

  custom_data = base64encode(file("../init-scripts/init-master.sh"))
  tags = {
    environment = "devops"
  }
}



resource "azurerm_linux_virtual_machine" "jenkins-slave" {
  name                  = "jenkins-slave-vm"
  location              = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name   = azurerm_resource_group.jenkins-resource-group.name
  network_interface_ids = [azurerm_network_interface.jenkins-newtork-interface-slave.id, ]
  size                  = "Standard_E2s_v3"

  admin_username = "devops"


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "myosdisk2"
    caching              = "None"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         =  64
  }

  admin_ssh_key {
    username   = "devops"
    public_key = file("../id_rsa.pub")
  }

  custom_data = base64encode(file("../init-scripts/init-slave.sh"))
  tags = {
    environment = "devops"
  }
}