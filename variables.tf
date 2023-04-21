variable "rg_name" {
  type = string
  description = "Azure Resource Group name"
  default = "rg-sandbox-devops"
}

variable "vnet_name" {
  type = string
  description = "Azure VNet name"
  default = "vnet-sandbox-devops"
}

variable "subnet_pgsql_flexible_name" {
  type = string
  description = "Azure PostgreSQL flexible subnet name"
  default = "subnet-sandbox-pgsql-flexible"
}

# The CIDR must be exist in the VNet address space
variable "subnet_pgsql_flexible_cidr" {
  type = string
  description = "Azure PostgreSQL flexible subnet CIDR"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags"
  default     = {
      created_by = "terraform-pgsql-flexible"
      sandbox    = "devops"
  }
}

variable "pgsql_flexible_params" {
  type = object({
    name                  = string
    version               = optional(number,13)
    storage_mb            = optional(number,32768)
    backup_retention_days = optional(number, 7)
    sku_name              = string
    db_name               = optional(string,null) # By default, a postgres database is created.
  })
  description     = "Azure PostgreSQL Flexible Server parameters"
  default         = null
  validation {
    condition     = var.pgsql_flexible_params.version > 11 && var.pgsql_flexible_params.storage_mb >= 32768 && var.pgsql_flexible_params.backup_retention_days >= 7 && var.pgsql_flexible_params.db_name != "postgres"
    error_message = "Wrong PostgreSQL Flexible Server parameter"
  }
}

variable "pgsql_flexible_credentials" {
  type = object({
    admin_login     = optional(string, "psqladmin")
    admin_password  = string
  })
  description     = "Azure PostgreSQL Flexible Server parameters"
  sensitive       = true
  default         = null
  validation {
    condition     = contains(["azure_pg_admin","admin","administrator","root","guest,public"], var.pgsql_flexible_credentials.admin_login) ? false : true && startswith(var.pgsql_flexible_credentials.admin_login, "pg_") ? false : true
    error_message = "Wrong PostgreSQL Flexible Server credentials"
  }
}

variable "vm_parameters" {
  type = object({
    subnet_name         = optional(string, "subnet-sandbox-devops")
    name                = string
    admin_username      = optional(string,"sandbox")
    ssh_public_key_file = optional(string,"~/.ssh/id_rsa.pub")
  })
  description     = "Vitual machine parameters"
  default         = null
}