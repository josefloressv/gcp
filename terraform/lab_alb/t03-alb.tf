# This taks used default VPC network
data "google_compute_network" "default_vpc" {
  name = "default"
}

# 1. Instance Template (Launch Template equivalent)
resource "google_compute_instance_template" "lb_backend_template" {
  name         = "lb-backend-template"
  machine_type = "e2-medium"
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = data.google_compute_network.default_vpc.id
    access_config {} # Ephemeral public IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    a2ensite default-ssl
    a2enmod ssl
    vm_hostname="$(curl -H "Metadata-Flavor:Google" \
      http://169.254.169.254/computeMetadata/v1/instance/name)"
      echo "Page served from: $vm_hostname" | \
      tee /var/www/html/index.html
    systemctl restart apache2
  EOT

  tags = ["allow-health-check"]

  # bests practice to avoid issues when updating instance templates
  # and use instead name prefixes in MIGs
  # lifecycle {
  #   create_before_destroy = true
  # }
}

# 2. Managed Instance Group (ASG equivalent)
resource "google_compute_region_instance_group_manager" "lb_backend_group" {
  name               = "lb-backend-group"
  region             = var.region
  base_instance_name = "web-server"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.lb_backend_template.id
    # TODO: Manage correctly dependencies when updating instance templates, for now deleted the MIG manually to update the instance template
  }

  # Crucial for ALB: Named port maps the traffic to the backend service
  named_port {
    name = "http"
    port = 80
  }
}

# 3. Firewall Rule to allow HTTP traffic and Health Checks
resource "google_compute_firewall" "allow_http_mig" {
  name    = "fw-allow-health-check"
  network = data.google_compute_network.default_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  # ACE Tip: Estos rangos son fijos para los Health Checks de Google
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

# 4. External Static IP for the Load Balancer (The Frontend IP)
resource "google_compute_global_address" "lb_static_ip" {
  name         = "lb-static-ipv4"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# 5. Health Check (Modern regional health check)
resource "google_compute_health_check" "http_health_check" {
  name               = "http-basic-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = "80"
  }
}

# 6 and 7. Backend Service (The heart of the ALB)
resource "google_compute_backend_service" "web_backend_service" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_health_check.id]

  backend {
    group = google_compute_region_instance_group_manager.lb_backend_group.instance_group
  }
}

# 8. URL Map (The Router / Listener Rules)
resource "google_compute_url_map" "web_map" {
  name            = "web-map-http"
  default_service = google_compute_backend_service.web_backend_service.id
}

# 9. Target HTTP Proxy (The Protocol Handler)
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web_map.id
}

# 10. Global Forwarding Rule (The Frontend / Anycast IP)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-content-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_static_ip.address
}