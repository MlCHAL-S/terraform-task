resource "google_compute_firewall" "allow_lb_http" {
  name    = "allow-lb-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["apache-server"]
}