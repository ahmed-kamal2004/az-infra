output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.secureadmin_ssh.private_key_openssh
}
output "vm_public_ip" {
  value      = azurerm_public_ip.jenkins-public-ip.ip_address
  depends_on = [azurerm_public_ip.jenkins-public-ip]
}
