#3. Backend Service and Health Check for Internal ALB
# Regional Health Check
resource "google_compute_region_health_check" "hc_internal" {
  name   = "ilb-health"
  region = var.region

  http_health_check {
    port         = 80
    request_path = "/2"
  }
}

# Regional Backend Service
resource "google_compute_region_backend_service" "internal_backend" {
  name                  = "prime-service"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.hc_internal.id]

  # For custom names, ensure the named port in the MIG matches this name
  port_name = var.named_port_custom

  backend {
    group           = google_compute_region_instance_group_manager.ilb_backend_group.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

}

#4. Routing and Forwarding Rule for Internal ALB
# Regional URL Map
resource "google_compute_region_url_map" "internal_url_map" {
  name            = "prime-lb"
  region          = var.region
  default_service = google_compute_region_backend_service.internal_backend.id
}

# 1. Network Resource (Using default VPC)
# Proxy-only subnet for regional envoy-based load balancers
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "172.16.0.0/23"
  network       = "default"
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Regional Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "internal_http_proxy" {
  name    = "internal-http-proxy"
  region  = "us-central1"
  url_map = google_compute_region_url_map.internal_url_map.id
}

# Forwarding Rule (The internal entry point)
resource "google_compute_forwarding_rule" "internal_forwarding_rule" {
  name       = "internal-forwarding-rule"
  region     = var.region
  depends_on = [google_compute_subnetwork.proxy_only_subnet]

  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.internal_http_proxy.id
  network               = "default"
  subnetwork            = "default" # Subnet where the IP will be allocated
}

resource "google_compute_firewall" "allow_backend_traffic" {
  name    = "allow-backend-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "172.16.0.0/23",  # Proxy-only subnet (from ILB traffic)
    "35.191.0.0/16",  # Health Check de Google
    "130.211.0.0/22", # Health Check de Google
    "10.128.0.0/20"   # Internal network (VPC us-central1, change if the subnet is different)
  ]

  target_tags = ["backend"]
}