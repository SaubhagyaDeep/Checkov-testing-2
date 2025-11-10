# VULNERABLE: Multiple storage security issues for Checkov testing

# CKV_GCP_18: Bucket is publicly readable
# CKV_GCP_20: Bucket is publicly writable  
# CKV_GCP_22: Bucket is not encrypted with customer-managed key
resource "google_storage_bucket" "vulnerable_public_bucket" {
  name     = "vulnerable-public-bucket-${random_id.bucket_suffix.hex}"
  location = "US"
  
  # VULNERABLE: Public access enabled
  uniform_bucket_level_access = false
  
  # VULNERABLE: No encryption specified (uses Google-managed keys only)
  # No encryption block = not using customer-managed keys
  
  # VULNERABLE: No versioning
  # versioning block missing
  
  # VULNERABLE: No lifecycle rules for security
  # lifecycle_rule blocks missing
}

# VULNERABLE: Public bucket access
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.vulnerable_public_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"  # Makes bucket publicly readable
}

resource "google_storage_bucket_iam_member" "public_write" {
  bucket = google_storage_bucket.vulnerable_public_bucket.name
  role   = "roles/storage.objectCreator" 
  member = "allAuthenticatedUsers"  # Allows any authenticated user to write
}

# VULNERABLE: Another bucket with different issues
resource "google_storage_bucket" "vulnerable_app_data" {
  name     = "vulnerable-app-data-${random_id.bucket_suffix.hex}"
  location = "US-CENTRAL1"
  
  # VULNERABLE: Uniform bucket-level access disabled
  uniform_bucket_level_access = false
  
  # VULNERABLE: No retention policy
  # retention_policy block missing
  
  # VULNERABLE: Logging disabled
  # logging block missing
}

# VULNERABLE: Storage bucket accessible to all project users
resource "google_storage_bucket_iam_member" "all_project_users" {
  bucket = google_storage_bucket.vulnerable_app_data.name
  role   = "roles/storage.admin"  # Full admin access
  member = "projectEditor:${var.project_id}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}