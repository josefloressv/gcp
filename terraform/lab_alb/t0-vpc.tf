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
