# 1. External Static IP for the Load Balancer (The Frontend IP)
resource "google_compute_address" "lb_static_ip" {
  name   = "network-lb-ip-1"
  region = var.region
}

# 2. Legacy HTTP Health Check (Required for Target Pools)
resource "google_compute_http_health_check" "basic_check" {
  name               = "basic-check"
  request_path       = "/"
  check_interval_sec = 5
  timeout_sec        = 5
}

# 3. Target Pool (The Backend Group)
resource "google_compute_target_pool" "www_pool" {
  name   = "www-pool"
  region = var.region

  instances = [
    google_compute_instance.vm_1.self_link,
    google_compute_instance.vm_2.self_link,
    google_compute_instance.vm_3.self_link,
  ]

  health_checks = [
    google_compute_http_health_check.basic_check.name,
  ]
}

# 4. Forwarding Rule (The Frontend / Listener)
resource "google_compute_forwarding_rule" "www_rule" {
  name       = "www-rule"
  region     = var.region
  port_range = "80"
  ip_address = google_compute_address.lb_static_ip.address
  target     = google_compute_target_pool.www_pool.self_link
}