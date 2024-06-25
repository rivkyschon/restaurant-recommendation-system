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
# Deploy cosmos db account
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "db_acc_name" {
  name          = var.resource_token
  resource_type = "azurerm_cosmosdb_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cosmosdb_account" "db" {
  name                            = azurecaf_name.db_acc_name.result
  location                        = var.location
  resource_group_name             = var.rg_name
  offer_type                      = "Standard"
  kind                            = "MongoDB"
  enable_automatic_failover       = false
  enable_multiple_write_locations = false
  mongo_server_version            = "4.0"
  tags                            = var.tags

  capabilities {
    name = "EnableServerless"
  }

  lifecycle {
    ignore_changes = [capabilities]
  }
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy cosmos mongo db and collections
# ------------------------------------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "Todo"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_cosmosdb_mongo_collection" "list" {
  name                = "TodoList"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_id"


  index {
    keys = ["_id"]
  }
}

resource "azurerm_cosmosdb_mongo_collection" "item" {
  name                = "TodoItem"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_id"

  index {
    keys = ["_id"]
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy private endpoint for cosmos db
# ------------------------------------------------------------------------------------------------------

resource "azurerm_private_endpoint" "cosmosdb_private_endpoint" {
  name                = "${var.resource_token}-cosmosdb-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "cosmosdb-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cosmosdb_account.db.id
    subresource_names              = ["mongodb"]
  }

}

# # Private DNS Zone
# resource "azurerm_private_dns_zone" "cosmos_db_private_dns_zone" {
#   name                = "privatelink.documents.azure.com"
#   resource_group_name = var.rg_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_db_private_dns_zone_link" {
#   name                  = "cosmos-db-private-dns-zone-link"
#   resource_group_name   = var.rg_name
#   private_dns_zone_name = azurerm_private_dns_zone.cosmos_db_private_dns_zone.name
#   virtual_network_id    = var.vnet_id 
# }

# # DNS Configuration for the Private Endpoint
# resource "azurerm_private_dns_a_record" "cosmos_db_private_dns_record" {
#   name                = azurerm_cosmosdb_account.db.name
#   zone_name           = azurerm_private_dns_zone.cosmos_db_private_dns_zone.name
#   resource_group_name = var.rg_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.cosmosdb_private_endpoint.private_service_connection[0].private_ip_address]
# }
