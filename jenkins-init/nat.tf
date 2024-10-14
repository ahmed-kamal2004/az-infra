# # Public IP address for NAT gateway
# resource "azurerm_public_ip" "nat_public_ip" {
#   name                = "public-ip-nat"
#   location            = azurerm_resource_group.jenkins-resource-group.location
#   resource_group_name = azurerm_resource_group.jenkins-resource-group.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# # NAT Gateway
# resource "azurerm_nat_gateway" "my_nat_gateway" {
#   name                = "nat-jenkins-gateway"
#   location            = azurerm_resource_group.jenkins-resource-group.location
#   resource_group_name = azurerm_resource_group.jenkins-resource-group.name
# }


# resource "azurerm_nat_gateway_public_ip_association" "example" {
#   nat_gateway_id       = azurerm_nat_gateway.my_nat_gateway.id
#   public_ip_address_id = azurerm_public_ip.nat_public_ip.id
# }


# # Associate NAT Gateway with Subnet
# resource "azurerm_subnet_nat_gateway_association" "example" {
#   subnet_id      = azurerm_subnet.jenkins-public-subnet.id
#   nat_gateway_id = azurerm_nat_gateway.my_nat_gateway.id
# }
