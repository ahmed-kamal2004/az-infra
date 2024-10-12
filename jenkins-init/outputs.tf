output "key_data" {
  value = azapi_resource_action.jenkins-ssh-public-key-gen.output.publicKey
}
output "vm_public_ip" {
  value = azurerm_public_ip.jenkins-public-ip.ip_address
}
