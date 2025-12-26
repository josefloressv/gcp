# Instance 1 External IP
output "testinstance_external_ip" {
  value = var.enable_test_instance ? google_compute_instance.testinstance[0].network_interface[0].access_config[0].nat_ip : ""
}

# Internal Load Balancer (static) IP
output "ilb_internal_ip" {
  value = google_compute_forwarding_rule.internal_forwarding_rule.ip_address
}

# Frontend Instance Public IP
output "frontend_instance_public_ip" {
  value = "http://${google_compute_instance.frontend_instance.network_interface[0].access_config[0].nat_ip}"
}