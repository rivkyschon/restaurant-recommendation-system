# ------------------------------------------------------------------------------------------------------
# KEYVAULT KEY FOR CONTAINER REGISTRY ENCRYPTION
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "key_name" {
  name           = "${var.resource_token}-key" 
  resource_type = "azurerm_key_vault_key"
  random_length = 0
  clean_input   = true
}

resource "azurerm_key_vault_key" "encryption_key" {
  name         = azurecaf_name.key_name.result
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048  
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  # Todo: Key expiration policies (set dates or configure rotation)
}

# ------------------------------------------------------------------------------------------------------
# KEYVAULT KEY FOR CONTAINER REGISTRY ENCRYPTION
# ------------------------------------------------------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry1"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Premium"

#   identity {
#     type = "UserAssigned"
#     identity_ids = [
#       azurerm_user_assigned_identity.example.id
#     ]
#   }

  encryption {
    enabled            = true
    key_vault_key_id   = data.azurerm_key_vault_key.encryption_key.id
  }

}