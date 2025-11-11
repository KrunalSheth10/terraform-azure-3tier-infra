# variables.tf

variable "project_name" {
  description = "The name of the project used for resource naming."
  type        = string
  default     = "azure-terraform-3tier"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}


# Database admin password (used for Key Vault and DB provisioning)
variable "db_admin_password" {
  description = "The admin password for the database server."
  type        = string
  sensitive   = true
}

# General database password (used for app connection string)
variable "db_password" {
  description = "The database password used in the connection string."
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

