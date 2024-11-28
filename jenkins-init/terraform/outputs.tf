# output "ssh_private_key" {
#   sensitive = true
#   value     = tls_private_key.secureadmin_ssh.private_key_openssh
# }
output "master_vm_public_ip" {
  value      = azurerm_public_ip.jenkins-public-ip-master.ip_address
  depends_on = [azurerm_public_ip.jenkins-public-ip-master, azurerm_linux_virtual_machine.jenkins-master, azurerm_network_interface.jenkins-newtork-interface-master]
}

# output "load_balancer_vm_public_ip" {
#   value      = azurerm_public_ip.jenkins-public-ip-load-balancer.ip_address
#   depends_on = [azurerm_public_ip.jenkins-public-ip-load-balancer, azurerm_linux_virtual_machine.jenkins-load-balancer, azurerm_network_interface.jenkins-newtork-interface-load-balancer]
# }

output "slave_vm_public_ip" {
  value      = azurerm_public_ip.jenkins-public-ip-slave.ip_address
  depends_on = [azurerm_public_ip.jenkins-public-ip-slave, azurerm_linux_virtual_machine.jenkins-slave, azurerm_network_interface.jenkins-newtork-interface-slave]
}
