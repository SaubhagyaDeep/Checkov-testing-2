# VULNERABLE: Reusable database module with security issues

resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  region          = var.region
  
  # VULNERABLE: Deletion protection can be disabled
  deletion_protection = var.deletion_protection
  
  settings {
    tier = var.tier
    
    # VULNERABLE: Conditional backup - can be disabled
    dynamic "backup_configuration" {
      for_each = var.enable_backup ? [1] : []
      content {
        enabled    = true
        start_time = "03:00"
        # VULNERABLE: No point in time recovery by default
        point_in_time_recovery_enabled = false
        # VULNERABLE: Short backup retention
        backup_retention_settings {
          retained_backups = 3
        }
      }
    }
    
    # VULNERABLE: Can allow public access
    ip_configuration {
      ipv4_enabled = var.enable_public_ip
      require_ssl  = var.require_ssl
      
      # VULNERABLE: Dynamic authorized networks can include 0.0.0.0/0
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }
    
    # VULNERABLE: Insecure database flags
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }
}