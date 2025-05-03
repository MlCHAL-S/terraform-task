output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.apache_forwarding_rule.ip_address
}