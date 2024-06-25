output "AZURE_COSMOS_CONNECTION_STRING_KEY" {
  value = local.cosmos_connection_string_key
}

output "AZURE_COSMOS_DATABASE_NAME" {
  value = module.cosmos.AZURE_COSMOS_DATABASE_NAME
}

output "AZURE_KEY_VAULT_ENDPOINT" {
  value     = module.keyvault.AZURE_KEY_VAULT_ENDPOINT
  sensitive = true
}

output "AZURE_LOCATION" {
  value = var.location
}

output "APPLICATIONINSIGHTS_CONNECTION_STRING" {
  value     = module.applicationinsights.APPLICATIONINSIGHTS_CONNECTION_STRING
  sensitive = true
}
