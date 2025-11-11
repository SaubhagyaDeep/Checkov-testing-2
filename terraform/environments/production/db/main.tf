# VULNERABLE: Production database with critical security issues
# This represents a worst-case scenario for production

module "vulnerable_production_db" {
  source = "../../../modules/vulnerable-db"
  
  instance_name = "production-db-critical"
  
  # VULNERABLE: Production database with public access
  enable_public_ip    = true
  deletion_protection = false
  enable_backup      = false
  require_ssl        = false
  
  # VULNERABLE: Open to internet in production
  authorized_networks = [
    {
      name = "production-allow-all"
      cidr = "0.0.0.0/0"
    }
  ]
  
  # VULNERABLE: Insecure flags in production
  database_flags = [
    {
      name  = "local_infile"
      value = "on"
    },
    {
      name  = "log_statement"
      value = "none"
    },
    {
      name  = "log_min_duration_statement"
      value = "-1"  # No slow query logging
    }
  ]
}

# VULNERABLE: Production database user with admin privileges
resource "google_sql_user" "production_admin" {
  name     = "root"
  instance = module.vulnerable_production_db.instance_name
  password = "production123"  # Weak password in production
}