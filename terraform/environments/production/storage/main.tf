# VULNERABLE: Production storage with severe security misconfigurations
# This represents a complete security failure for production storage

# VULNERABLE: Public production bucket with sensitive data
resource "google_storage_bucket" "production_sensitive_data" {
  name     = "momentum-production-sensitive-data"
  location = "US"
  
  # VULNERABLE: No access restrictions
  uniform_bucket_level_access = false
  
  # VULNERABLE: No versioning for critical data
  versioning {
    enabled = false
  }
  
  # VULNERABLE: No lifecycle management
  lifecycle_rule {
    condition {
      age = 0  # Never delete
    }
    action {
      type = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }
}

# VULNERABLE: Public read access on production data
resource "google_storage_bucket_iam_member" "production_public_read" {
  bucket = google_storage_bucket.production_sensitive_data.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# VULNERABLE: Production bucket with public write access
resource "google_storage_bucket" "production_uploads" {
  name     = "momentum-production-uploads"
  location = "US"
  
  uniform_bucket_level_access = false
  
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_member" "production_public_write" {
  bucket = google_storage_bucket.production_uploads.name
  role   = "roles/storage.objectAdmin"
  member = "allUsers"
}

# VULNERABLE: Unencrypted production bucket for customer data
resource "google_storage_bucket" "production_customer_data" {
  name     = "momentum-production-customer-pii"
  location = "US"
  
  uniform_bucket_level_access = false
  
  # VULNERABLE: No encryption specified for sensitive data
  # encryption block is missing entirely
  
  versioning {
    enabled = false
  }
}