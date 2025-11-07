output "db_admin_password_secret_uri" {
  value       = azurerm_key_vault_secret.db_admin_password.id
  description = "URI of the database admin password stored in Key Vault"
}
