# 1. Instance Template
# Equivalent to: gcloud compute instance-templates create primecalc
resource "google_compute_instance_template" "primecalc" {
  name         = "primecalc"
  machine_type = "e2-medium"
  region       = "us-east1" # Replace with your target region

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    # Note: No access_config block here. 
    # Omitting it is the equivalent of --no-address (No Public IP).
  }

  # Loading startup script from a local file
  # Equivalent to: --metadata-from-file startup-script=backend.sh
  metadata_startup_script = file("${path.module}/backend.sh")

  # Network tags for firewall targeting
  tags = ["backend"]
}

# 3. Managed Instance Group (ASG equivalent)
resource "google_compute_region_instance_group_manager" "ilb_backend_group" {
  name               = "backend"
  region             = var.region
  base_instance_name = "backend"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.primecalc.id
  }

  # Crucial for ALB and ILB: Named port maps the traffic to the backend service
  named_port {
    name = var.named_port_custom # Testing custom names, usually "http"
    port = 80
  }

  # Force replacement policy on update to avoid issues with instance template updates
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 0 # Additional instances during update, in this case none
    max_unavailable_fixed = 3 # Max instances down during update
  }
}