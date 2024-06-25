terraform {
  required_providers {
    azurerm = {
      version = "~>3.97.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.24"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy container instance
# ------------------------------------------------------------------------------------------------------
resource "azurerm_container_group" "container_instance" {
  name                = var.container_group_name
  resource_group_name = var.rg_name
  location            = var.location
  ip_address_type     = "Public"
  dns_name_label      = var.dns_name_label
  os_type             = var.os_type

  container {
    name   = var.container_name
    image  = var.image_name
    cpu    = var.cpu_core_number
    memory = var.memory_size
    ports {
      port     = 443
      protocol = "TCP"
    }
    environment_variables = {
      COSMOS_DB_CONNECTION_STRING = var.cosmos_connection_string
    }
  }
}
