resource "azurerm_virtual_machine" "jenkins" {
  name                  = var.jenkins-resource-group-name
  resource_group_name   = var.jenkins-resource-group-name
  location              = var.jenkins-resource-group-location
  network_interface_ids = [azurerm_network_interface.jenkins-newtork-interface.id]
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  vm_size = "Standard_DS2_v3"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "24_04-lts"
    version   = "latest"
  }

  os_profile {
    custom_data    = base64encode(file("./init.sh"))
    computer_name  = "jenkins"
    admin_username = "devops"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = azapi_resource_action.jenkins-ssh-public-key-gen.output.publicKey
      path     = "/home/ubuntu/.ssh/authorized_keys"
    }
  }
}
