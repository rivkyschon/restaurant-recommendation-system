output "AZURE_KEY_VAULT_ENDPOINT" {
  value     = azurerm_key_vault.kv.vault_uri
  sensitive = true
}

output "AZURE_KEY_VAULT_ID" {
  value     = azurerm_key_vault.kv.id
  sensitive = true
}

output "AZURE_KEY_VAULT_NAME" {
  value     = azurerm_key_vault.kv.name
  sensitive = true
}