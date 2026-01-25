# Instance 1 External IP
output "Instance1_external_name" {
  value = google_compute_instance.vm_1.name
}

output "Instance1_external_ip" {
  value = google_compute_instance.vm_1.network_interface[0].access_config[0].nat_ip
}
