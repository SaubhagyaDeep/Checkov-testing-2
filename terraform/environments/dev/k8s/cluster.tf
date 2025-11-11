# VULNERABLE: Kubernetes security issues for Checkov testing

# CKV_GCP_25: GKE cluster not running latest stable version
# CKV_GCP_26: GKE cluster master authentication disabled
# CKV_GCP_27: GKE cluster basic authentication enabled
# CKV_GCP_30: GKE cluster legacy metadata endpoints enabled
resource "google_container_cluster" "vulnerable_cluster" {
  name     = "vulnerable-gke-cluster"
  location = "us-central1-a"
  
  # VULNERABLE: Old Kubernetes version
  min_master_version = "1.24.0"  # Outdated version
  
  # VULNERABLE: Legacy metadata endpoints enabled
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # VULNERABLE: Basic authentication enabled
  master_auth {
    username = "admin"
    password = "vulnerable123"  # Weak password
    
    # VULNERABLE: Client certificate enabled
    client_certificate_config {
      issue_client_certificate = true
    }
  }
  
  # VULNERABLE: Legacy ABAC enabled
  enable_legacy_abac = true
  
  # VULNERABLE: Network policy disabled
  network_policy {
    enabled = false
  }
  
  # VULNERABLE: Private cluster disabled
  private_cluster_config {
    enable_private_nodes   = false  # Nodes have public IPs
    enable_private_endpoint = false # Master endpoint is public
  }
  
  # VULNERABLE: Pod security policy disabled
  pod_security_policy_config {
    enabled = false
  }
  
  # VULNERABLE: Monitoring and logging minimal
  monitoring_config {
    enable_components = []  # No monitoring components
  }
  
  logging_config {
    enable_components = []  # No logging components
  }
  
  # VULNERABLE: Master authorized networks allows all
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "allow-all"
    }
  }
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
}

# VULNERABLE: Node pool with security issues
resource "google_container_node_pool" "vulnerable_nodes" {
  name       = "vulnerable-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.vulnerable_cluster.name
  node_count = 1
  
  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    
    # VULNERABLE: Full OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"  # Full access
    ]
    
    # VULNERABLE: Service account with broad permissions
    service_account = google_service_account.vulnerable_gke_sa.email
    
    # VULNERABLE: No image scanning
    # image_type not specified, uses default
    
    # VULNERABLE: Metadata server v1 enabled (legacy)
    metadata = {
      disable-legacy-endpoints = "false"
    }
  }
}

# VULNERABLE: GKE service account with excessive permissions
resource "google_service_account" "vulnerable_gke_sa" {
  account_id   = "vulnerable-gke-sa"
  display_name = "Vulnerable GKE Service Account"
}

resource "google_project_iam_member" "vulnerable_gke_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.vulnerable_gke_sa.email}"
}