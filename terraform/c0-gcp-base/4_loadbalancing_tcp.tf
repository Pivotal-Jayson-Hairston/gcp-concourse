///////////////////////////////////////////////
//////// Health Checks ////////////////////////
///////////////////////////////////////////////

// Go Router Health check
resource "google_compute_http_health_check" "cf-gorouter" {
  name                = "${var.gcp_terraform_prefix}-gorouter"
  port                = 8080
  request_path        = "/health"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

// TCP Router Health check
resource "google_compute_http_health_check" "cf-tcp" {
  name                = "${var.gcp_terraform_prefix}-tcp-lb"
  host                = "tcp.sys.${google_dns_managed_zone.env_dns_zone.dns_name}"
  port                = 80
  request_path        = "/health"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}

///////////////////////////////////////////////
//////// TCP Target Pools     /////////////////
///////////////////////////////////////////////

// GoRouter target pool
resource "google_compute_target_pool" "cf-gorouter" {
  name = "${var.gcp_terraform_prefix}-gorouter"

  health_checks = [
    "${google_compute_http_health_check.cf-gorouter.name}",
  ]
}

// SSH-Proxy target pool
resource "google_compute_target_pool" "cf-ssh" {
  name = "${var.gcp_terraform_prefix}-ssh-proxy"
}

// TCP Router target pool
resource "google_compute_target_pool" "cf-tcp" {
  name = "${var.gcp_terraform_prefix}-cf-tcp-lb"

  health_checks = [
    "${google_compute_http_health_check.cf-tcp.name}",
  ]
}

///////////////////////////////////////////////
//////// TCP Forwarding Rules /////////////////
///////////////////////////////////////////////

// Doppler forwarding rule
resource "google_compute_forwarding_rule" "cf-gorouter" {
  name        = "${var.gcp_terraform_prefix}-gorouter-wss"
  target      = "${google_compute_target_pool.cf-tcp.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.ssh-and-doppler-tcp.address}"
}

// SSH Proxy forwarding rule
resource "google_compute_forwarding_rule" "cf-ssh" {
  name        = "${var.gcp_terraform_prefix}-ssh-proxy"
  target      = "${google_compute_target_pool.cf-ssh.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.ssh-and-doppler-tcp.address}"
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-tcp" {
  name        = "${var.gcp_terraform_prefix}-cf-tcp-lb"
  target      = "${google_compute_target_pool.cf-tcp.self_link}"
  port_range  = "1024-65535"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-tcp.address}"
}
