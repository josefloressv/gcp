
# Instance 1
resource "google_compute_instance" "vm_1" {
  name         = "web1"
  machine_type = "e2-small"
  zone         = var.zone
  tags         = ["network-lb-tag"] # Matches our firewall rule

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.auto_vpc.id
    access_config {
      # Empty block assigns an ephemeral external IP (Required for internet access to fetch updates)
    }
  }

  # Equivalent to AWS User Data
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "
    <h3>Web Server: web1</h3>" | tee /var/www/html/index.html
  EOT
}

# Instance 2 (Similar to VM 1)
resource "google_compute_instance" "vm_2" {
  name         = "web2"
  machine_type = "e2-small"
  zone         = var.zone
  tags         = ["network-lb-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.auto_vpc.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "
    <h3>Web Server: web2</h3>" | tee /var/www/html/index.html
  EOT
}


# Instance 2 (Similar to VM 1)
resource "google_compute_instance" "vm_3" {
  name         = "web3"
  machine_type = "e2-small"
  zone         = var.zone
  tags         = ["network-lb-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.auto_vpc.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "
    <h3>Web Server: web3</h3>" | tee /var/www/html/index.html
  EOT
}

# Regla de Firewall para Health Checks y Tráfico Externo
resource "google_compute_firewall" "allow_http" {
  name    = "www-firewall-network-lb"
  network = google_compute_network.auto_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # ACE Tip: Estos rangos son fijos para los Health Checks de Google
  source_ranges = ["0.0.0.0/0", "35.191.0.0/16", "209.85.152.0/22"]
  target_tags   = ["network-lb-tag"]
}