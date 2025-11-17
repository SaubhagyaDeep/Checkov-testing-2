resource "google_compute_firewall" "allow_all" {
  name          = "terragoat-${var.environment}-firewall"
  network       = google_compute_network.vpc.id
  source_ranges = ["125.53.43.12/32"]
  allow {
    protocol = "tcp"
    ports    = ["0-1000"]
  }
}
