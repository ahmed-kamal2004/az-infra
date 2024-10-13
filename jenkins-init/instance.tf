resource "azurerm_virtual_machine" "jenkins" {
  name                  = var.jenkins-resource-group-name
  location              = azurerm_resource_group.jenkins-resource-group.location
  resource_group_name   = azurerm_resource_group.jenkins-resource-group.name
  network_interface_ids = [azurerm_network_interface.jenkins-newtork-interface.id]
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  vm_size = "Standard_D2s_v3"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_profile {
    custom_data    = base64encode(file("./init.sh"))
    computer_name  = "devops"
    admin_username = "devops"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = tls_private_key.secureadmin_ssh.public_key_openssh
      path     = "/home/devops/.ssh/authorized_keys"
    }
  }
}
