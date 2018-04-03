variable "create_network" {
  description = "The trigger for creating Azure network"
}

variable "azure_network_name" {
  description = "The Azure Network name"
}

variable "azure_network" {
  description = "The Azure Network"
}

variable "azure_private_subnets" {
  description = "The Azure private subnets"
  type        = "list"
}

variable "azure_public_subnets" {
  description = "The Azure public subnets"
  type        = "list"
}

variable "azure_resource_name" {
  description = "The Azure Resource name"
}

variable "azure_location" {
  description = "The Azure location"
}

variable "create_bastion" {
  description = "The trigger for creating Bastion NAT Gateway"
}

#variable "" {
#  description = "The "
#}

