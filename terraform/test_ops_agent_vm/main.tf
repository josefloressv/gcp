# Instance 1 with Ops Agent
# Using default Compute Engine service account which has necessary permissions
# for logging and monitoring in sandbox environments
resource "google_compute_instance" "vm_1" {
  name         = "vm-ops-agent-1"
  machine_type = "e2-medium"
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

  # Use default Compute Engine service account with cloud-platform scope
  # This provides necessary permissions for Ops Agent to send logs and metrics
  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Startup script to install Ops Agent
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Install Ops Agent
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    
    # Start the agent
    sudo systemctl start google-cloud-ops-agent
    sudo systemctl enable google-cloud-ops-agent
  EOT
}
