# Definición de la VPC
resource "google_compute_network" "auto_vpc" {
  name                    = "web-server-vpc"
  auto_create_subnetworks = true
}
