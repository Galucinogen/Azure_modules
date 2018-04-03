##################B
# Azure          #
# Resource Group #
##################
resource "azurerm_resource_group" "dev" {
  name      = "${var.azure_resource_name}"
  location  = "${var.azure_location}"
}

#################
# Azure Network #
#################
resource "azurerm_virtual_network" "vnetwork" {
  count               = "${var.create_network ? 1 : 0 }"
  name                = "${var.azure_network_name}"
  location            = "${azurerm_resource_group.dev.location}"
  address_space       = ["${var.azure_network}"]
  resource_group_name = "${azurerm_resource_group.dev.name}"
}

###################
# Private Subnets #
###################
resource "azurerm_subnet" "azure_private_subnet" {
  count                     = "${var.create_network ? length(var.azure_private_subnets) : 0 }"
  name                      = "Private_Subnet_${count.index+1}"
  virtual_network_name      = "${azurerm_virtual_network.vnetwork.name}"
  resource_group_name       = "${azurerm_resource_group.dev.name}"
  address_prefix            = "${element(var.azure_private_subnets, count.index)}"
  network_security_group_id = "${azurerm_network_security_group.default_security_group.id}"
}

##################
# Private Routes #
##################
resource "azurerm_route_table" "azure_private_route_table" {
  count               = "${var.create_network && length(var.azure_private_subnets) > 0 ? 1 : 0 }"
  name                = "PrivateRouteTable"
  location            = "${azurerm_resource_group.dev.location}"
  resource_group_name = "${azurerm_resource_group.dev.name}"
}

resource "azurerm_route" "azure_private_route" {
  count                       = "${var.create_network && length(var.azure_private_subnets) > 0 ? length(var.azure_private_subnets) : 0 }"
  name                        = "AcceptancePrivateRoute"
  resource_group_name         = "${azurerm_resource_group.dev.name}"
  route_table_name            = "${azurerm_route_table.azure_private_route_table.name}"
  address_prefix              = "${element(var.azure_private_subnets, count.index)}"
  next_hop_type               = "VirtualAppliance"
  next_hop_in_ip_address      = "${azurerm_network_interface.bastionnic.private_ip_address}"

  depends_on = ["azurerm_network_interface.bastionnic"]

}

##################
# Public Subnets #
##################
resource "azurerm_subnet" "azure_public_subnet" {
  count                     = "${var.create_network && length(var.azure_public_subnets) > 0 ? length(var.azure_public_subnets) : 0 }"
  name                      = "Public_subnet_${count.index+1}"
  virtual_network_name      = "${azurerm_virtual_network.vnetwork.name}"
  resource_group_name       = "${azurerm_resource_group.dev.name}"
  address_prefix            = "${element(var.azure_public_subnets, count.index)}"
  network_security_group_id = "${azurerm_network_security_group.default_security_group.id}"
}

#################
# Public Routes #
#################

##########################
# Default Security Group #
##########################
resource "azurerm_network_security_group" "default_security_group" {
  name                = "DefaultSecurityGroup"
  location            = "${azurerm_resource_group.dev.location}"
  resource_group_name = "${azurerm_resource_group.dev.name}"

  #  tags                        = "${var.tags}"
}

resource "azurerm_network_security_rule" "security_rule_ssh" {
  name                        = "ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.dev.name}"
  network_security_group_name = "${azurerm_network_security_group.default_security_group.name}"
}
