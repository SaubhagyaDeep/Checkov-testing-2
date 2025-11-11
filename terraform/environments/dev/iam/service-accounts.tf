# VULNERABLE: IAM security issues for Checkov testing

# CKV_GCP_35: Default service account has full access to all Cloud APIs
resource "google_compute_instance" "vulnerable_vm" {
  name         = "vulnerable-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network = "default"
    # VULNERABLE: Public IP assigned
    access_config {
      # Ephemeral public IP
    }
  }
  
  # VULNERABLE: Using default service account with full scope
  service_account {
    email  = "default"  # Default Compute Engine service account
    scopes = ["cloud-platform"]  # Full access to all GCP APIs
  }
  
  # VULNERABLE: SSH keys in metadata
  metadata = {
    ssh-keys = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7... admin@vulnerable-host"
  }
  
  # VULNERABLE: Serial console access enabled
  enable_display = true
}

# VULNERABLE: Over-privileged service account
resource "google_service_account" "vulnerable_app_sa" {
  account_id   = "vulnerable-app-sa"
  display_name = "Vulnerable Application Service Account"
}

# CKV_GCP_40: IAM policy grants overly broad privileges
resource "google_project_iam_member" "vulnerable_app_admin" {
  project = var.project_id
  role    = "roles/owner"  # Full project ownership
  member  = "serviceAccount:${google_service_account.vulnerable_app_sa.email}"
}

# VULNERABLE: Multiple overly broad IAM bindings
resource "google_project_iam_member" "vulnerable_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"  # Full storage admin access
  member  = "serviceAccount:${google_service_account.vulnerable_app_sa.email}"
}

resource "google_project_iam_member" "vulnerable_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"  # Full compute admin access
  member  = "serviceAccount:${google_service_account.vulnerable_app_sa.email}"
}

# VULNERABLE: Service account with key stored in plain text
resource "google_service_account_key" "vulnerable_sa_key" {
  service_account_id = google_service_account.vulnerable_app_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# VULNERABLE: IAM binding for all authenticated users
resource "google_project_iam_member" "all_authenticated_users" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "allAuthenticatedUsers"  # Any authenticated Google user
}