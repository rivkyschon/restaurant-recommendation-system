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

data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Key Vault
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "kv_name" {
  name          = var.resource_token
  resource_type = "azurerm_key_vault"
  random_length = 0
  clean_input   = true
}

resource "azurerm_key_vault" "kv" {
  name                        = azurecaf_name.kv_name.result
  location                    = var.location
  resource_group_name         = var.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enabled_for_disk_encryption = true

  tags = var.tags

  # network_acls {
  #   default_action             = "Deny"
  #   bypass                     = "AzureServices"
  #   ip_rules                   = ["192.117.165.7"]
  #   virtual_network_subnet_ids = [var.subnet_id]
  # }
}

# ------------------------------------------------------------------------------------------------------
# Deploy access policies to Key Vault
# ------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_access_policy" "app" {
  count        = length(var.access_policy_object_ids)
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.access_policy_object_ids[count.index]

  key_permissions         = ["Get", "List", "Create", "Update", "Delete", "Import", "Backup", "Restore", "Recover", "Purge", "GetRotationPolicy"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"]
}

resource "azurerm_key_vault_access_policy" "user" {
  count        = var.principal_id == "" ? 0 : 1
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.principal_id

  secret_permissions = ["Get", "Set", "List", "Delete", "Purge"]
  key_permissions    = ["Get", "GetRotationPolicy", "List", "Create", "Update", "Delete", "Import", "Backup", "Restore", "Recover", "Purge"]
}

# ------------------------------------------------------------------------------------------------------
# Deploy secrets to Key Vault
# ------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "secrets" {
  count        = length(var.secrets)
  name         = var.secrets[count.index].name
  value        = var.secrets[count.index].value
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault.kv,
    azurerm_key_vault_access_policy.user,
    azurerm_key_vault_access_policy.app
  ]
}

# ------------------------------------------------------------------------------------------------------
# Deploy encryption key to Key Vault
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "key_name" {
  name          = "${var.resource_token}-key"
  resource_type = "azurerm_key_vault_key"
  random_length = 0
  clean_input   = true
}

resource "azurerm_key_vault_key" "encryption_key" {
  name         = azurecaf_name.key_name.result
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_key_vault_access_policy.user,
    azurerm_key_vault_access_policy.app
  ]
  # Todo: Key expiration policies (set dates or configure rotation)
}
