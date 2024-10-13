# resource "azapi_resource" "jenkins-ssh-public-key" {
#   type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   name      = "jenkins-key"
#   location  = var.jenkins-resource-group-location
#   parent_id = azurerm_resource_group.jenkins-resource-group.id
# }
# resource "azapi_resource_action" "jenkins-ssh-public-key-gen" {
#   type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   resource_id = azapi_resource.jenkins-ssh-public-key.id
#   action      = "generateKeyPair"
#   method      = "POST"

#   response_export_values = ["publicKey", "privateKey"]
# }


resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
