
resource "azurerm_resource_group" "terr-state" {
  name     = "terr-state"
  location = "West Europe"
}

resource "azurerm_storage_account" "terr-state" {
  name                     = "terr-state-storage-account"
  resource_group_name      = azurerm_resource_group.terr-state.name
  location                 = azurerm_resource_group.terr-state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "state"
  }
}

resource "azurerm_storage_container" "terr-state" {
  name                  = "terr-state"
  storage_account_name  = azurerm_storage_account.terr-state.name
  container_access_type = "private"
}
