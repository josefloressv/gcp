
# Instance 1
resource "google_compute_instance" "vm_1" {
  name         = "www1"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["network-lb-tag"] # Matches our firewall rule

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      # Empty block assigns an ephemeral external IP (Required for internet access to fetch updates)
    }
  }

  # Equivalent to AWS User Data
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "Hi from Instance 1" > /var/www/html/index.html
  EOT
}

# Instance 2 (Similar to VM 1)
resource "google_compute_instance" "vm_2" {
  name         = "www2"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["network-lb-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "Hi from Instance 2" > /var/www/html/index.html
  EOT
}


# Instance 2 (Similar to VM 1)
resource "google_compute_instance" "vm_3" {
  name         = "www3"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["network-lb-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    echo "Hi from Instance 2" > /var/www/html/index.html
  EOT
}

