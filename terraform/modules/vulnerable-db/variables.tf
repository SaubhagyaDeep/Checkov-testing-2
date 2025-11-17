variable "instance_name" {
  description = "Name of the database instance"
  type        = string
}

variable "database_version" {
  description = "Database version"
  type        = string
  default     = "POSTGRES_13"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "tier" {
  description = "Machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false  # VULNERABLE: Defaults to false
}

variable "enable_backup" {
  description = "Enable database backups"
  type        = bool
  default     = true  # VULNERABLE: Defaults to false
}

variable "enable_public_ip" {
  description = "Enable public IP access"
  type        = bool
  default     = true  # VULNERABLE: Defaults to true
}

variable "require_ssl" {
  description = "Require SSL connections"
  type        = bool
  default     = false  # VULNERABLE: Defaults to false
}

variable "authorized_networks" {
  description = "Authorized networks for database access"
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "allow-all"
      cidr = "0.0.0.0/0"  # VULNERABLE: Default allows all
    }
  ]
}

variable "database_flags" {
  description = "Database flags"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "local_infile"
      value = "on"  # VULNERABLE: Default enables local infile
    },
    {
      name  = "log_statement" 
      value = "none"  # VULNERABLE: No query logging
    }
  ]
}
