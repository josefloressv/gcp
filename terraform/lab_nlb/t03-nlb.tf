# 1. External Static IP for the Load Balancer (The Frontend IP)
resource "google_compute_address" "lb_static_ip" {
  name   = "network-lb-static-ip"
  region = var.region
}

# 2. Legacy HTTP Health Check (Required for Target Pools)
resource "google_compute_http_health_check" "basic_check" {
  name               = "basic-check"
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 5
}