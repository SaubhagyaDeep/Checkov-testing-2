# VULNERABLE: Storage module with multiple security issues

resource "google_storage_bucket" "main" {
  name     = var.bucket_name
  location = var.location
  
  # VULNERABLE: Uniform bucket-level access disabled by default
  uniform_bucket_level_access = var.uniform_bucket_level_access
  
  # VULNERABLE: No versioning by default
  dynamic "versioning" {
    for_each = var.enable_versioning ? [1] : []
    content {
      enabled = true
    }
  }
  
  # VULNERABLE: No encryption configuration
  # Missing encryption block means no customer-managed keys
  
  # VULNERABLE: No logging configuration
  # Missing logging block
  
  # VULNERABLE: No retention policy
  # Missing retention_policy block
  
  # VULNERABLE: No lifecycle rules
  # Missing lifecycle_rule blocks
}

# VULNERABLE: Optional public access
resource "google_storage_bucket_iam_member" "public_read" {
  count  = var.enable_public_read ? 1 : 0
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "public_write" {
  count  = var.enable_public_write ? 1 : 0
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectCreator"
  member = "allAuthenticatedUsers"
}

# VULNERABLE: Broad IAM permissions
resource "google_storage_bucket_iam_member" "admin_access" {
  for_each = var.admin_members
  bucket   = google_storage_bucket.main.name
  role     = "roles/storage.admin"
  member   = each.value
}