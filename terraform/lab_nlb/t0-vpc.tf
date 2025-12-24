# Definición de la VPC
resource "google_compute_network" "vpc_network" {
  name                    = "web-server-vpc"
  auto_create_subnetworks = false
}

# Subred Regional
resource "google_compute_subnetwork" "subnet" {
  name          = "web-server-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Regla de Firewall para Health Checks y Tráfico Externo
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-and-health-checks"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # ACE Tip: Estos rangos son fijos para los Health Checks de Google
  source_ranges = ["0.0.0.0/0", "35.191.0.0/16", "209.85.152.0/22"]
  target_tags   = ["network-lb-tag"]
}