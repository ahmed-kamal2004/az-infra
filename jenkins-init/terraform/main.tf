resource "azurerm_resource_group" "jenkins-resource-group" {
  location = var.jenkins-resource-group-location
  name     = var.jenkins-resource-group-name
}
