# Create public IPs
resource "azurerm_public_ip" "bastionpublicip" {
  count                        = "${var.create_bastion ? 1 : 0}"
  name                         = "BastionPublicIP"
  location                     = "${var.azure_location}"
  resource_group_name          = "${azurerm_resource_group.dev.name}"
  public_ip_address_allocation = "Static"

  tags {
    environment = "Terraform Demo"
  }
}

# Create network interface
resource "azurerm_network_interface" "bastionnic" {
  count                     = "${var.create_bastion ? 1 : 0}"
  name                      = "BastionNIC"
  location                  = "${var.azure_location}"
  resource_group_name       = "${azurerm_resource_group.dev.name}"
  network_security_group_id = "${azurerm_network_security_group.default_security_group.id}"
  enable_ip_forwarding      = "true"

  ip_configuration {
    name                          = "BastionNicConfiguration"
    subnet_id                     = "${element(azurerm_subnet.azure_public_subnet.*.id, count.index)}"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = "${azurerm_public_ip.bastionpublicip.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "bastionstorageaccount" {
  count                    = "${var.create_bastion ? 1 : 0}"
  name                     = "bastionstorage"
  location                 = "${var.azure_location}"
  resource_group_name      = "${azurerm_resource_group.dev.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "Terraform Demo"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "bastion" {
  count                 = "${var.create_bastion ? 1 : 0}"
  name                  = "Bastion"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.dev.name}"
  network_interface_ids = ["${azurerm_network_interface.bastionnic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.4"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
    custom_data    = "${base64encode(file("${path.module}/files/nat.sh"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqwTjrOy/wo9GRd2AQznF0Zx1l99cdJIReJRvBlBWlnvHN1QJNNt0LAW5W+xVlZr4RQsaRLuIDhkorz9519Ye1CvcUaQY7hKz+7HC8SERmG8NclOkHC6z1wyk0edJgdoI5XdGQPYYZAQf3/NqbsPw6loKLw+HqRfA+wwJybd5p5wNBddFo0E+5jq32rdLfHrHdzDD5G93XYEQz0vGEgPTydCTQQyX/0BwbO8dZoONaloARKzE40rNDzF/x367DabYAwiq/4rKSCE1Uw/FQMrkOoq1UWPlXLKgAuHQxVoMV6f9r6+TFVGtmXlvBnOkO0jWU3xp9F4gFXi9lyOqM4VlF3ikIgqlmZ175ijLYDNt7S1DMSrk8FTUTk/HI8KDQImelQ23kcJIa/1DLl9ewn5ac4TGqSSThamM3H3lQucHALGqIIRx1DFyQWhmr/BBAmwHtY4BX+ExFpgfcCAJHPPVwvx5GNnDqlapQmfR+jFSyTN7L2vToalbsBFpcTZAUYNfmGlvGH64xrzLTX4ozAVpV0obermLp6Qgdi95asVyTc4MlyLhYK+0BWZWaLSoSzfnSv4d94BIOqpJ8cBpHeSt3N5SjgdgW6rlGRxXRgHUlKOjqdMz1AudVgmjaoyw0sA5jB8PB2ooml4nV0GAdQe7kWzWVUx4lXlo3b3zWyDU6/w== avgur@avgur.od.ua"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.bastionstorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "Terraform Bastion Host"
  }
}
