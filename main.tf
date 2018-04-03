############
# Provider #
#   Azure  #
############
module "azure_network" {
  source = "modules/azure_network"

  create_network     = true
  create_bastion     = true

  azure_resource_name = "DEV_TEST_RESOURCE"
  azure_network_name  = "DEV_TEST_NETWORK"
  azure_network       = "172.16.0.0/16"
  azure_location      = "Central US"

  azure_private_subnets = ["172.16.0.0/24", "172.16.1.0/24"]
  azure_public_subnets  = ["172.16.3.0/24", "172.16.4.0/24"]
}
