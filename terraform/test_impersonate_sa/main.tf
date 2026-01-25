########################################
# Locals & Data
########################################
locals {
  prefix = "ace-imp"
}
data "google_project" "project" {}

########################################
# APIs (optional but helpful in labs)
########################################
resource "google_project_service" "iamcredentials" {
  project            = data.google_project.project.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = data.google_project.project.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = data.google_project.project.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

########################################
# Buckets
########################################
resource "google_storage_bucket" "bucket_a" {
  project                     = data.google_project.project.project_id
  name                        = "${local.prefix}-a-${data.google_project.project.project_id}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket_b" {
  project                     = data.google_project.project.project_id
  name                        = "${local.prefix}-b-${data.google_project.project.project_id}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

########################################
# Service Accounts
########################################
# Target SA to be impersonated (least privilege to Bucket A only)
resource "google_service_account" "gcs_access_sa" {
  project      = data.google_project.project.project_id
  account_id   = "${local.prefix}-gcs-access"
  display_name = "ACE Impersonated GCS Access SA"
}

# Backend SA attached to VM (allowed to impersonate target SA)
resource "google_service_account" "backend_sa" {
  project      = data.google_project.project.project_id
  account_id   = "${local.prefix}-backend"
  display_name = "ACE Backend VM SA (Impersonator)"
}

########################################
# Bucket A IAM for impersonated SA (least privilege)
########################################
resource "google_storage_bucket_iam_member" "a_viewer" {
  bucket = google_storage_bucket.bucket_a.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gcs_access_sa.email}"
}

resource "google_storage_bucket_iam_member" "a_creator" {
  bucket = google_storage_bucket.bucket_a.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.gcs_access_sa.email}"
}

########################################
# Bucket B: explicitly no access for impersonated SA
# (No bindings on purpose)
########################################

########################################
# Allow backend SA to impersonate target SA
########################################
resource "google_service_account_iam_member" "backend_token_creator" {
  service_account_id = google_service_account.gcs_access_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.backend_sa.email}"
}

########################################
# Compute Engine VM (backend)
########################################
resource "google_compute_instance" "backend_vm" {
  project      = data.google_project.project.project_id
  name         = "${local.prefix}-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email = google_service_account.backend_sa.email
    # Use cloud-platform to avoid scope-related false negatives in the lab.
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}

########################################
# Outputs
########################################
output "bucket_a" { value = google_storage_bucket.bucket_a.name }
output "bucket_b" { value = google_storage_bucket.bucket_b.name }

output "backend_vm_name" { value = google_compute_instance.backend_vm.name }
output "backend_vm_zone" { value = var.zone }

output "backend_sa_email" { value = google_service_account.backend_sa.email }
output "impersonated_sa_email" { value = google_service_account.gcs_access_sa.email }