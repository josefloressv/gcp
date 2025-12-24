# Instance 1 External IP
output "Instance1_external_ip" {
  value = google_compute_instance.vm_1.network_interface[0].access_config[0].nat_ip
}

# Instance 2 External IP
output "Instance2_external_ip" {
  value = google_compute_instance.vm_2.network_interface[0].access_config[0].nat_ip
}

# Instance 3 External IP
output "Instance3_external_ip" {
  value = google_compute_instance.vm_3.network_interface[0].access_config[0].nat_ip
}

# Network Load Balancer (static) IP
output "nlb_static_ip" {
  value = google_compute_address.lb_static_ip.address
}