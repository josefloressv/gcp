resource "google_compute_instance" "frontend_instance" {
  name         = "frontend"
  machine_type = "e2-standard-2"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Empty block assigns an ephemeral external IP (Required for internet access to fetch updates)
    }
  }
  # Loading startup script from a local file
  # Equivalent to: --metadata-from-file startup-script=frontend.sh
  metadata_startup_script = file("${path.module}/frontend.sh") # Make sure to change the Load Balancer IP inside the script

  # Network tags for firewall targeting
  tags = ["frontend"]
}


resource "google_compute_firewall" "allow_internet_traffic" {
  name    = "allow-internet-traffic-frontend"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow from anywhere
  target_tags   = ["frontend"]
}