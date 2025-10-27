terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "demo-insecure-project"
  region  = "us-central1"
}

# ❌ Misconfigured GCS bucket
resource "google_storage_bucket" "public_bucket" {
  name                        = "demo-public-bucket-12345"
  location                    = "US"
  force_destroy               = true           # Risk: allows accidental deletion of all data
  uniform_bucket_level_access = false          # Risk: ACLs instead of IAM
  public_access_prevention    = "unspecified"  # Risk: allows public access
  versioning {
    enabled = false                             # Risk: no versioning
  }
  encryption {
    default_kms_key_name = ""                   # Risk: missing CMEK
  }
}

# ❌ Makes the bucket publicly readable
resource "google_storage_bucket_iam_member" "public_reader" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ❌ Open firewall rule
resource "google_compute_firewall" "open_firewall" {
  name    = "allow-all-ingress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]   # Risk: open to the world
}

# ❌ Cloud SQL instance with public IP, weak security settings
resource "google_sql_database_instance" "weak_sql" {
  name             = "weak-sql-instance"
  database_version = "MYSQL_5_7"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true       # Risk: public IP
      require_ssl     = false      # Risk: allows unencrypted connections
      authorized_networks {
        name  = "open"
        value = "0.0.0.0/0"       # Risk: allows all IPs
      }
    }

    backup_configuration {
      enabled = false              # Risk: no backups
    }
  }

  deletion_protection = false      # Risk: accidental data loss
}

