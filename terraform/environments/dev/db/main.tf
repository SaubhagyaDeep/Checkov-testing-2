# VULNERABLE: Multiple database security issues for Checkov testing

# CKV_GCP_6: Database backup is disabled
# CKV_GCP_7: Database is publicly accessible  
# CKV_GCP_8: Database is not encrypted
# CKV_GCP_10: Local infile is enabled (security risk)
resource "google_sql_database_instance" "vulnerable_primary" {
  name             = "vulnerable-db-primary"
  database_version = "POSTGRES_13"
  region          = "us-central1"
  
  # VULNERABLE: Deletion protection disabled
  deletion_protection = false
  
  settings {
    tier = "db-f1-micro"
    
    # VULNERABLE: No backup configuration
    # backup_configuration block missing entirely
    
    # VULNERABLE: Publicly accessible
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"  # Opens to entire internet
      }
    }
    
    # VULNERABLE: Various insecure database flags
    database_flags {
      name  = "local_infile"
      value = "on"  # Security risk - allows local file access
    }
    
    database_flags {
      name  = "log_statement"
      value = "none"  # No query logging
    }
  }
}

# CKV_GCP_1: SSL not required for connections
resource "google_sql_database_instance" "vulnerable_replica" {
  name                 = "vulnerable-db-replica"
  database_version     = "POSTGRES_13"
  region              = "us-east1"
  master_instance_name = google_sql_database_instance.vulnerable_primary.name
  
  settings {
    tier = "db-f1-micro"
    
    # VULNERABLE: SSL not enforced
    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = false  # Allows unencrypted connections
    }
  }
}

# VULNERABLE: Database user with weak password policy
resource "google_sql_user" "vulnerable_user" {
  name     = "admin"
  instance = google_sql_database_instance.vulnerable_primary.name
  password = "admin123"  # Weak password
}